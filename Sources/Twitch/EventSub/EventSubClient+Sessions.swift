import Foundation

extension EventSubClient {
  // MARK: - Subscription capacity

  func reserveSubscriptionSlot(
    revision: UInt64? = nil
  ) async throws -> (slot: Reservation, sessionID: String) {
    let revision = revision ?? self.revision
    try checkRevision(revision)

    let slot = try await waitForAvailableSlot()

    do {
      try checkRevision(revision)
      guard let session = sessions.active[slot.session], session.slots.contains(slot.id) else {
        throw EventSubError.disconnected(with: CancellationError())
      }

      return (slot, session.twitchSessionID)
    } catch {
      releaseReservation(slot)
      throw error
    }
  }

  private func waitForAvailableSlot() async throws -> Reservation {
    let requestID = UUID()

    return try await withTaskCancellationHandler {
      try await queueAndWaitForSlot(requestID)
    } onCancel: {
      // Return to the actor to remove the request from its queue.
      Task { await self.cancelSlotRequest(requestID) }
    }
  }

  private func queueAndWaitForSlot(_ requestID: UUID) async throws -> Reservation {
    try await withCheckedThrowingContinuation { reply in
      sessions.waiters.append(SlotRequest(id: requestID, reply: reply))
      serveSlotWaiters()
    }
  }

  func releaseReservation(_ slot: Reservation) {
    guard sessions.active[slot.session]?.releaseSlot(slot.id) == true else { return }

    if sessions.active[slot.session]?.slots.isEmpty == true {
      closeSession(slot.session)
    }

    serveSlotWaiters()
  }

  func serveSlotWaiters() {
    guard !isRetired, !sessions.waiters.isEmpty else { return }

    for (sessionID, session) in sessions.active {
      grantSlots(in: sessionID, upTo: session.availableSlots)
      if sessions.waiters.isEmpty { return }
    }

    openSessionIfNeeded()
  }

  private func grantSlots(in sessionID: UUID, upTo capacity: Int) {
    guard capacity > 0 else { return }

    let requests = sessions.waiters.prefix(capacity)
    sessions.waiters.removeFirst(requests.count)

    for request in requests {
      let slot = Reservation(id: request.id, session: sessionID)
      sessions.active[sessionID]?.slots.insert(slot.id)
      request.reply.resume(returning: slot)
    }
  }

  private func cancelSlotRequest(_ requestID: UUID) async {
    guard let index = sessions.waiters.firstIndex(where: { $0.id == requestID }) else { return }

    let waiter = sessions.waiters.remove(at: index)
    if sessions.waiters.isEmpty {
      // The last waiter can return once its unused socket has closed.
      await cancelOpeningSession()?.value
    }

    waiter.reply.resume(throwing: CancellationError())
  }

  func failSlotWaiters(throwing error: any Error) {
    let waiters = sessions.waiters
    sessions.waiters.removeAll()

    for waiter in waiters { waiter.reply.resume(throwing: error) }
  }
}

extension EventSubClient {
  struct Reservation: Sendable {
    let id: UUID
    let session: UUID
  }

  struct SlotRequest {
    fileprivate let id: UUID
    fileprivate let reply: CheckedContinuation<Reservation, any Error>
  }

  struct Sessions {
    var active: [UUID: Session] = [:]
    var opening: (id: UUID, handshake: SocketHandshake)?
    var closing: [UUID: Task<Void, Never>] = [:]
    var waiters: [SlotRequest] = []
  }

  struct Session {
    private static let subscriptionLimit = 300

    var twitchSessionID: String
    var connection: EventSubConnection
    var replacement: SocketHandshake?
    var drainingConnections: [UUID: EventSubConnection] = [:]
    var slots: Set<UUID> = []
    var notifications = NotificationBuffer()

    fileprivate var availableSlots: Int {
      // Hold off on new POSTs until the replacement's welcome arrives.
      replacement == nil ? Self.subscriptionLimit - slots.count : 0
    }

    fileprivate mutating func releaseSlot(_ id: UUID) -> Bool {
      guard slots.remove(id) != nil else { return false }

      notifications.discardPendingFrames(for: id)
      return true
    }
  }
}
