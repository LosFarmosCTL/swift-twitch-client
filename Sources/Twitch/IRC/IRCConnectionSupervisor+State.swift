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

  var snapshot: IRCState { state.snapshot }

  func stateUpdates() -> AsyncStream<IRCState> {
    let id = UUID()
    let (stream, observer) = AsyncStream<IRCState>.makeStream()

    observer.yield(snapshot)

    guard !state.isEnded else {
      observer.finish()
      return stream
    }

    stateObservers[id] = observer
    observer.onTermination = { [weak self] _ in
      Task {
        await self?.removeStateObserver(id)
      }
    }

    return stream
  }

  func finishStateObservers() {
    for observer in stateObservers.values {
      observer.finish()
    }

    stateObservers.removeAll()
  }

  private func removeStateObserver(_ id: UUID) {
    stateObservers[id] = nil
  }
}
