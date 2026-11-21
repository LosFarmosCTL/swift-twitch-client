import Foundation

extension EventSubClient {
  // MARK: - Closing subscriptions

  func failSubscriptions(in sessionID: UUID, error: EventSubError) {
    for subscription in Array(subscriptions.values) {
      switch subscription.phase {
      case .active(_, let slot) where slot.session == sessionID:
        closeSubscription(subscription, error: error, deleteRemote: false)
      case .posting(let slot) where slot.session == sessionID:
        closeSubscription(subscription, error: error)
      default: break
      }
    }
  }

  func closeSubscription(
    _ subscription: Subscription, error: (any Error)? = nil, deleteRemote: Bool = true
  ) {
    let phase = subscription.phase
    if case .closing = phase { return }

    subscription.phase = .closing
    let observers = subscription.observers.values
    subscription.observers.removeAll()

    switch phase {
    case .reserving:
      // The resolver checks cancellation before handing a slot back to setup.
      subscription.setupTask?.cancel()
    case .posting(let slot):
      beginClosingReservation(slot)
    case .active(let id, let slot):
      if deleteRemote {
        beginClosingReservation(slot)
        Task { await deleteAndRemove(subscription, id: id, slot: slot) }
      } else {
        finishCleanup(subscription, id: id, slot: slot)
      }

      for observer in observers {
        observer.finish(error as? EventSubError)
      }
      return

    case .closing:
      return
    }

    let setupFailure = error ?? CancellationError()
    for observer in observers { observer.failSetup(setupFailure) }
  }

  func deleteAndRemove(_ subscription: Subscription, id: String?, slot: Reservation?) async {
    guard let id else {
      finishCleanup(subscription, id: nil, slot: slot)
      return
    }

    if remoteSubscriptions[id] == nil { remoteSubscriptions[id] = subscription }

    do {
      try await deleteRemoteSubscription(id, credentials: subscription.credentials)
      finishCleanup(subscription, id: id, slot: slot)
    } catch {
      guard let slot else {
        finishCleanup(subscription, id: id, slot: nil)
        return
      }
      reconcileCleanup(
        subscription, target: .knownID(id), slot: slot, retryAfter: rateLimitDelay(error))
    }
  }

  private func finishCleanup(_ subscription: Subscription, id: String?, slot: Reservation? = nil) {
    // Releasing the last slot can close the session and stop its reconciliation tasks.
    subscription.reconciliation = nil
    if let slot { releaseReservation(slot) }
    if let id, remoteSubscriptions[id] === subscription {
      remoteSubscriptions[id] = nil
    }

    if subscriptions[subscription.key] === subscription {
      subscriptions[subscription.key] = nil
    }
    subscription.setupTask = nil
    subscription.finishCleanup()
  }

  private func deleteRemoteSubscription(_ id: String, credentials: TwitchCredentials) async throws {
    do {
      _ = try await TwitchClient.helix(
        for: .deleteEventSubSubscription(subscriptionID: id),
        credentials: credentials, network: network, decoder: decoder, diagnostics: diagnostics)
    } catch HelixError.twitchError(_, 404, _), HelixError.parsingErrorFailed(404, _) {
      return
    }
  }

  // MARK: - Background reconciliation

  func reconcileCleanup(
    _ subscription: Subscription, target: CleanupTarget, slot: Reservation,
    retryAfter: Duration = .zero
  ) {
    guard sessions.active[slot.session] != nil else {
      finishCleanup(subscription, id: target.id)
      return
    }

    let key = subscription.key
    let task = Task<Void, Never> { [weak self] in
      await self?.retryCleanup(key, slot: slot, target: target, retryAfter: retryAfter)
    }
    subscription.reconciliation = (slot, target, task)
  }

  func stopReconcilingSubscriptions(in sessionID: UUID) {
    for subscription in Array(subscriptions.values) {
      guard let cleanup = subscription.reconciliation, cleanup.slot.session == sessionID
      else { continue }
      cleanup.task.cancel()
      finishCleanup(subscription, id: cleanup.target.id)
    }
  }

  private func retryCleanup(
    _ key: ConflictKey, slot: Reservation, target initialTarget: CleanupTarget, retryAfter: Duration
  ) async {
    var target = initialTarget
    var backoff = Duration.seconds(1)
    var serverDelay = retryAfter
    var emptyScans = 0
    var lastSessionID: String?

    while !Task.isCancelled {
      do {
        try await Task.sleep(for: max(backoff, serverDelay))
      } catch { return }

      guard let subscription = subscriptions[key],
        subscription.reconciliation?.slot.id == slot.id,
        let session = sessions.active[slot.session]
      else { return }

      backoff = min(backoff * 2, .seconds(60))
      serverDelay = .zero

      guard session.replacement == nil else { continue }
      let sessionID = session.twitchSessionID
      if lastSessionID != sessionID {
        emptyScans = 0
        lastSessionID = sessionID
      }

      do {
        let id = try await findCleanupSubscription(
          target, for: subscription, slot: slot, sessionID: sessionID)
        try checkCleanupSession(slot, sessionID: sessionID)

        if let id {
          emptyScans = 0
          target = .knownID(id)
          subscription.reconciliation?.target = target
          remoteSubscriptions[id] = subscription
          try await deleteRemoteSubscription(id, credentials: subscription.credentials)
          try Task.checkCancellation()
        } else if target.id == nil {
          // A POST may still have been processing during the first lookup.
          emptyScans += 1
          guard emptyScans >= 3 else { continue }
        }

        finishCleanup(subscription, id: target.id, slot: slot)
        return
      } catch {
        serverDelay = rateLimitDelay(error)
      }
    }
  }

  // MARK: - Looking up remote subscriptions

  private func findCleanupSubscription(
    _ target: CleanupTarget, for subscription: Subscription, slot: Reservation, sessionID: String
  ) async throws -> String? {
    let credentials = subscription.credentials
    switch target {
    case .knownID(let id):
      let page = try await cleanupPage(filter: .subscriptionID(id), credentials: credentials)
      try checkCleanupSession(slot, sessionID: sessionID)

      // A lookup by ID returns either the subscription or an empty list.
      guard page.cursor == nil, page.subscriptions.allSatisfy({ $0.id == id })
      else { throw CleanupLookupError.inconclusive }
      return page.subscriptions.isEmpty ? nil : id

    case .unknownID:
      return try await findUnconfirmedSubscription(
        subscription.key, slot: slot, sessionID: sessionID, credentials: credentials)
    }
  }

  private func findUnconfirmedSubscription(
    _ key: ConflictKey, slot: Reservation, sessionID: String,
    credentials: TwitchCredentials
  ) async throws -> String? {
    var cursor: String?
    var seenCursors = Set<String>()
    var found: String?

    repeat {
      let page = try await cleanupPage(
        filter: .type(key.type), after: cursor, credentials: credentials)
      try checkCleanupSession(slot, sessionID: sessionID)

      for match in page.subscriptions
      where key.matches(match, in: sessionID) {
        guard !match.id.isEmpty,
          found == nil || found == match.id,
          remoteSubscriptions[match.id] == nil
        else { throw CleanupLookupError.inconclusive }
        found = match.id
      }

      cursor = page.cursor
      if let cursor, !seenCursors.insert(cursor).inserted { throw CleanupLookupError.inconclusive }
    } while cursor != nil

    return found
  }

  private func cleanupPage(
    filter: EventSubSubscriptionFilter, after cursor: String? = nil, credentials: TwitchCredentials
  ) async throws -> GetEventSubSubscriptionsResponse {
    try await TwitchClient.helix(
      for: .getEventSubSubscriptions(filter: filter, after: cursor, requiresValidPagination: true),
      credentials: credentials, network: network, decoder: decoder, diagnostics: diagnostics
    ).value
  }

  private func checkCleanupSession(_ slot: Reservation, sessionID: String) throws {
    try Task.checkCancellation()
    guard let session = sessions.active[slot.session],
      session.twitchSessionID == sessionID, session.replacement == nil
    else { throw CleanupLookupError.inconclusive }
  }

  private func rateLimitDelay(_ error: any Error) -> Duration {
    guard case HelixError.rateLimited(let failure) = error,
      let reset = failure.metadata.rateLimit?.resetAt
    else { return .zero }
    return .seconds(max(0, reset.timeIntervalSinceNow))
  }

  // MARK: - Reconciliation state

  enum CleanupTarget: Sendable {
    case knownID(String)
    case unknownID

    var id: String? {
      if case .knownID(let id) = self { id } else { nil }
    }
  }

  private enum CleanupLookupError: Error { case inconclusive }
}

extension EventSubClient.ConflictKey {
  fileprivate func matches(
    _ subscription: GetEventSubSubscriptionsResponse.Subscription, in sessionID: String
  ) -> Bool {
    subscription.type == type && subscription.version == version
      && subscription.condition == condition && subscription.transport.method == "websocket"
      && subscription.transport.sessionID == sessionID
  }
}
