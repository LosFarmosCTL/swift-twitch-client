import Foundation

/// Keeps the registrations for one managed channel in scope until a topic ends.
internal enum ChatEventSubTopics {
  struct Topic: Sendable {
    let observe:
      @Sendable (EventSubClient, any EventSubHandler, UInt64) async throws
        -> EventSubObservation

    init<E: Event>(_ subscription: EventSubSubscription<E>) {
      observe = { client, handler, revision in
        try await client.observe(for: subscription, handler: handler, revision: revision)
      }
    }
  }

  enum Update: Sendable {
    case ready
    case event(EventSubNotification<any Event>)
    case ended(EventSubError?)
    case setupFailed(any Error)
  }

  private struct Handler: EventSubHandler {
    let feed: AsyncStream<Update>.Continuation

    func yield(_ notification: EventSubNotification<any Event>) { feed.yield(.event(notification)) }
    func finish() { end(.ended(nil)) }
    func finish(throwing error: EventSubError) { end(.ended(error)) }

    func end(_ update: Update) {
      feed.yield(update)
      feed.finish()
    }
  }

  static func run(
    _ topics: [Topic], client: EventSubClient, revision: UInt64,
    receive: @escaping @Sendable (Update) async -> Void
  ) async {
    let (updates, feed) = AsyncStream<Update>.makeStream()
    let handler = Handler(feed: feed)

    await withTaskGroup(of: EventSubObservation?.self) { group in
      for topic in topics {
        group.addTask {
          await register(topic, on: client, revision: revision, handler: handler)
        }
      }

      await forwardUpdates(updates, topicCount: topics.count, receive: receive)

      group.cancelAll()
      for await registration in group {
        if let registration { await client.removeObservation(registration) }
      }
    }
  }

  private static func register(
    _ topic: Topic, on client: EventSubClient, revision: UInt64, handler: Handler
  ) async -> EventSubObservation? {
    do {
      let observation = try await topic.observe(client, handler, revision)
      handler.feed.yield(.ready)
      return observation
    } catch {
      if !Task.isCancelled { handler.end(.setupFailed(error)) }
      return nil
    }
  }

  private static func forwardUpdates(
    _ updates: AsyncStream<Update>, topicCount: Int,
    receive: @Sendable (Update) async -> Void
  ) async {
    // Deliver notifications during setup. Readiness waits for every topic.
    var remaining = topicCount
    for await update in updates {
      if case .ready = update {
        remaining -= 1
        if remaining > 0 { continue }
      }
      await receive(update)
    }
  }
}
