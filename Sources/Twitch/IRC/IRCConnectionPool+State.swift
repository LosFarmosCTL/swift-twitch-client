import Foundation
import TwitchIRC

extension IRCConnectionPool {
  struct State: Sendable {
    var entries: [UUID: Entry] = [:]
    var active = false
    var ended = false
    var terminalError: Error?
    var globalUserState: GlobalUserState?
    var userStateConnectionID: UUID?
    var statuses: [String: IRCChannelStatus] = [:]
  }

  var snapshot: IRCState { state.snapshot }

  func stateUpdates() -> AsyncStream<IRCState> {
    let id = UUID()
    let (stream, observer) = AsyncStream<IRCState>.makeStream()

    observer.yield(snapshot)

    guard !state.ended else {
      observer.finish()
      return stream
    }

    stateObservers[id] = observer
    observer.onTermination = { [weak self] _ in
      Task { await self?.removeStateObserver(id) }
    }

    return stream
  }

  func finishStateObservers() {
    for observer in stateObservers.values { observer.finish() }
    stateObservers.removeAll()
  }

  private func removeStateObserver(_ id: UUID) {
    stateObservers[id] = nil
  }
}

extension IRCConnectionPool.State {
  mutating func removeEntry(_ id: UUID) -> IRCConnectionPool.Entry? {
    let entry = entries.removeValue(forKey: id)

    if userStateConnectionID == id {
      userStateConnectionID = entries.keys.min { $0.uuidString < $1.uuidString }

      if let next = userStateConnectionID, let state = entries[next]?.globalUserState {
        globalUserState = state
      }
    }

    return entry
  }

  var snapshot: IRCState {
    let recoveries = entries.compactMap { _, entry -> IRCRecovery? in
      guard var recovery = entry.recovery else { return nil }

      recovery.channels = entry.channels
      return recovery
    }.sorted { $0.connectionID.uuidString < $1.connectionID.uuidString }

    let status: IRCState.Status

    if let terminalError {
      status = .failed(.init(terminalError: terminalError))
    } else if ended {
      status = .shutdown
    } else if !active {
      status = .idle
    } else if !recoveries.isEmpty {
      status = .reconnecting
    } else if entries.values.contains(where: { !$0.ready }) {
      status = .connecting
    } else {
      status = .connected
    }

    return IRCState(
      status: status,
      channels: statuses,
      recoveries: recoveries,
      globalUserState: globalUserState)
  }
}
