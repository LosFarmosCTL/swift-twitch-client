import Foundation

extension EventSubClient {
  func receive(_ frame: Frame, in sessionID: UUID) {
    guard let subscription = remoteSubscriptions[frame.subscription.id] else {
      return bufferEarlyFrame(frame, in: sessionID)
    }

    guard case .active(_, let slot) = subscription.phase else { return }
    guard slot.session == sessionID else { return }

    switch frame {
    case .notification(let frame):
      deliver(frame, to: subscription, in: sessionID)
    case .revocation(let revocation):
      closeSubscription(
        subscription,
        error: EventSubError.revocation(revocation),
        deleteRemote: false)
    }
  }

  func deliver(
    _ frame: EventSubNotificationFrame, to subscription: Subscription, in sessionID: UUID
  ) {
    guard frame.subscription.type == subscription.key.type,
      frame.subscription.version == subscription.key.version,
      let notification = sessions.active[sessionID]?.notifications.decode(
        frame, as: subscription.eventType, using: decoder)
    else { return }

    for observer in subscription.observers.values { observer.handler.yield(notification) }
  }

  private func bufferEarlyFrame(_ frame: Frame, in sessionID: UUID) {
    guard let account = credentials.userID else { return }

    let incoming = frame.subscription
    let key = ConflictKey(
      account: account,
      type: incoming.type,
      version: incoming.version,
      condition: incoming.condition)

    guard let subscription = subscriptions[key] else { return }
    guard case .posting(let slot) = subscription.phase else { return }
    guard slot.session == sessionID else { return }

    sessions.active[sessionID]?.notifications
      .buffer(frame, subscriptionID: incoming.id, for: slot.id)
  }

  func takePendingFrames(
    _ subscriptionID: String,
    for slot: Reservation
  ) throws -> [EventSubNotificationFrame] {
    let frames = try sessions.active[slot.session]?.notifications
      .takePendingFrames(subscriptionID, for: slot.id)

    if let frames { return frames } else { throw CancellationError() }
  }

  enum Frame {
    case notification(EventSubNotificationFrame)
    case revocation(EventSubRevocation)

    var subscription: EventSubMessage.Subscription {
      switch self {
      case .notification(let frame): frame.subscription
      case .revocation(let revocation): revocation.subscription
      }
    }
  }

  struct NotificationBuffer {
    private var pending: [UUID: [String: PendingFrames]] = [:]
    private var received = RecentIDs(capacity: 100)

    fileprivate mutating func decode(
      _ frame: EventSubNotificationFrame, as eventType: any Event.Type, using decoder: JSONDecoder
    ) -> EventSubNotification<any Event>? {
      guard !received.contains(frame.messageID),
        let notification = try? frame.decode(as: eventType, using: decoder)
      else { return nil }

      // Only a successfully decoded delivery should suppress a later replay.
      _ = received.insert(frame.messageID)
      return notification
    }

    fileprivate mutating func takePendingFrames(
      _ subscriptionID: String,
      for slotID: UUID
    ) throws -> [EventSubNotificationFrame] {
      let frames = pending.removeValue(forKey: slotID)?[subscriptionID]

      if let revocation = frames?.revocation {
        throw EventSubError.revocation(revocation)
      }

      return frames?.notifications ?? []
    }

    fileprivate mutating func buffer(_ frame: Frame, subscriptionID: String, for slotID: UUID) {
      var frames = pending[slotID]?[subscriptionID] ?? PendingFrames()

      switch frame {
      case .notification(let frame):
        frames.notifications.append(frame)
      case .revocation(let revocation):
        frames.revocation = revocation
      }

      pending[slotID, default: [:]][subscriptionID] = frames
    }

    mutating func discardPendingFrames(for id: UUID) { pending[id] = nil }
  }

  private struct PendingFrames {
    var notifications: [EventSubNotificationFrame] = []
    var revocation: EventSubRevocation?
  }
}
