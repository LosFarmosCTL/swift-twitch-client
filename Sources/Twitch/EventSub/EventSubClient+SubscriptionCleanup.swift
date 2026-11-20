import Foundation

extension EventSubClient {
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
        releaseReservation(slot)
        completeCleanup(subscription, remoteID: id)
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
    if let id {
      if remoteSubscriptions[id] == nil { remoteSubscriptions[id] = subscription }

      if await deleteRemoteSubscription(id, credentials: subscription.credentials), let slot {
        releaseReservation(slot)
      }
    } else if let slot {
      releaseReservation(slot)
    }

    completeCleanup(subscription, remoteID: id)
  }

  private func deleteRemoteSubscription(_ id: String, credentials: TwitchCredentials) async -> Bool
  {
    do {
      _ = try await TwitchClient.helix(
        for: .deleteEventSubSubscription(subscriptionID: id),
        credentials: credentials, network: network, decoder: decoder, diagnostics: diagnostics)
      return true
    } catch HelixError.twitchError(_, 404, _), HelixError.parsingErrorFailed(404, _) {
      return true
    } catch {
      // Until this socket closes, Twitch may still count the subscription.
      return false
    }
  }

  private func completeCleanup(_ subscription: Subscription, remoteID: String?) {
    if let remoteID, remoteSubscriptions[remoteID] === subscription {
      remoteSubscriptions[remoteID] = nil
    }

    subscriptions[subscription.key] = nil
    subscription.setupTask = nil
    subscription.finishCleanup()
  }
}
