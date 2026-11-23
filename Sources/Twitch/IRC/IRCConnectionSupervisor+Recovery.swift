import Foundation
import TwitchIRC

extension IRCConnectionSupervisor {
  func run() async {
    var failures = 0

    while !state.isEnded {
      let reason: IRCRecovery.Reason

      do {
        let stream = try await connectForAttempt()
        failures = 0
        reason = try await relay(stream)
      } catch {
        switch error {
        case IRCError.loginFailed, IRCError.capabilitiesRejected, IRCError.invalidInput,
          is TwitchAuthenticationError:
          await disconnect(throwing: error)
          return
        default:
          reason = .init(error: error)
        }
      }

      guard !state.isEnded else { return }

      failures += 1

      let delay = scheduleRecovery(
        reason: interruptionReason ?? reason,
        failures: failures
      )

      interruptionReason = nil
      await connection.disconnect()

      do { try await Task.sleep(for: delay) } catch { return }
    }
  }

  private func connectForAttempt() async throws -> AsyncThrowingStream<IncomingMessage, any Error> {
    connectionAttemptID = UUID()
    if state.recovery?.retryAt != nil {
      updateState { $0.recovery?.retryAt = nil }
    }

    let stream = try await connection.connect()
    guard !state.isEnded else { throw CancellationError() }

    updateState { state in
      state.status = .connected
      state.recovery = nil
    }
    return stream
  }

  private func relay(
    _ stream: AsyncThrowingStream<IncomingMessage, Error>
  ) async throws -> IRCRecovery.Reason {
    for try await message in stream {
      guard !state.isEnded else { return .connectionClosed }

      if case .reconnect = message { return .serverRequestedReconnect }
      if case .globalUserState(let state) = message {
        updateState { $0.globalUserState = state }
      }

      continuation?.yield(.message(message))
    }

    return .connectionClosed
  }

  private func scheduleRecovery(
    reason: IRCRecovery.Reason,
    failures: Int
  ) -> Duration {
    let delay = Self.reconnectDelay(failures: failures)

    updateState { state in
      state.status = .reconnecting
      state.recovery = IRCRecovery(
        connectionID: id,
        role: role,
        channels: [],
        reason: reason,
        attempt: failures,
        retryAt: Date().addingTimeInterval(delay.timeInterval))
    }

    return delay
  }

  private static func reconnectDelay(failures: Int) -> Duration {
    let ceiling = 250 * (1 << min(max(failures, 1), 6))

    return .milliseconds(Int.random(in: (ceiling / 2)...ceiling))
  }
}
