import Foundation
import TwitchIRC

extension IRCConnectionSupervisor {
  struct State: Sendable {
    var status: IRCState.Status = .idle
    var recovery: IRCRecovery?
    var globalUserState: GlobalUserState?
    var terminalError: Error?

    var isEnded: Bool {
      switch status {
      case .shutdown, .failed:
        true
      default:
        false
      }
    }

    var snapshot: IRCState {
      IRCState(
        status: status,
        recoveries: recovery.map { [$0] } ?? [],
        globalUserState: globalUserState)
    }
  }

  func waitUntilConnected() async throws {
    try Task.checkCancellation()
    if state.status == .connected { return }
    if state.isEnded { throw state.terminalError ?? IRCError.disconnected }

    let id = UUID()
    let (ready, reply) = AsyncThrowingStream<Void, any Error>.makeStream()
    connectionWaiters[id] = reply
    defer { connectionWaiters[id] = nil }

    for try await _ in ready {}
    try Task.checkCancellation()
  }

  func completeConnectionWaiters() {
    let error: (any Error)?
    if state.status == .connected {
      error = nil
    } else if state.isEnded {
      error = state.terminalError ?? IRCError.disconnected
    } else {
      return
    }

    for reply in connectionWaiters.values { reply.finish(throwing: error) }
    connectionWaiters.removeAll()
  }
}
