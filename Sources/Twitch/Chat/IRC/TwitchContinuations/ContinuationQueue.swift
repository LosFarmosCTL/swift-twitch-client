import Foundation
import TwitchIRC

internal struct ContinuationQueue {
  private var continuations: [any TwitchContinuation] = []

  mutating func register(
    _ twitchContinuation: any TwitchContinuation, timeout: Duration?,
    run task: @escaping () async throws -> Void
  ) async throws {
    continuations.append(twitchContinuation)

    let timeoutTask = Task {
      if let timeout {
        try await Task.sleep(for: timeout)
        throw IRCError.timedOut
      }
    }

    // ensure that continuations get cleaned up from the list after they were completed
    defer { continuations.removeAll(where: { $0 === twitchContinuation }) }

    try await withCheckedThrowingContinuation { continuation in
      Task {
        await twitchContinuation.setContinuation(continuation)

        try await task()

        do { try await timeoutTask.value } catch is IRCError {
          await twitchContinuation.cancel(throwing: IRCError.timedOut)
        }
      }
    }
  }

  mutating func completeAny(matching message: IncomingMessage) async {
    for continuation in continuations {
      _ = await continuation.check(message: message)
    }
  }
}
