import Foundation

extension TwitchIRCClient {
  /// Immediately yields current state, then the latest snapshots.
  /// Slow consumers may skip intermediate states. Cancelling an observer leaves IRC active.
  public func stateUpdates() -> AsyncStream<IRCState> {
    let id = UUID()

    let (stream, observer) = AsyncStream<IRCState>.makeStream(
      bufferingPolicy: .bufferingNewest(1)
    )

    observer.yield(state)

    guard terminalState == nil else {
      observer.finish()
      return stream
    }

    stateObservers[id] = observer
    observer.onTermination = { [weak self] _ in
      Task { await self?.removeStateObserver(id) }
    }

    return stream
  }

  func observeConnectionStates() async {
    let readUpdates = await readConnectionPool.stateUpdates()

    guard terminalState == nil else { return }

    readStateTask = Task { [weak self] in
      for await snapshot in readUpdates {
        await self?.accept(snapshot, role: .read)
      }
    }

    if let writeConnection {
      let updates = await writeConnection.stateUpdates()

      guard terminalState == nil else { return }

      writeStateTask = Task { [weak self] in
        for await snapshot in updates {
          await self?.accept(snapshot, role: .write)
        }
      }
    }
  }

  private func accept(_ snapshot: IRCState, role: IRCRecovery.Role) {
    guard terminalState == nil else { return }

    switch role {
    case .read:
      readState = snapshot

    case .write:
      writeState = snapshot
    }

    let read = readState
    let write = writeState

    updateState { state in
      state.channels = read.channels
      state.recoveries = read.recoveries + write.recoveries

      state.globalUserState = read.globalUserState

      state.status = sessionStatus(
        read: read.status,
        write: write.status,
        recovering: !state.recoveries.isEmpty
      )
    }
  }

  private func sessionStatus(
    read: IRCState.Status,
    write: IRCState.Status,
    recovering: Bool
  ) -> IRCState.Status {
    if !started { return .idle }

    if case .failed = read { return read }
    if case .failed = write { return write }

    if recovering { return .reconnecting }

    if read == .connected, writeConnection == nil || write == .connected {
      return .connected
    }

    return .connecting
  }

  func finishStateObservers() {
    for observer in stateObservers.values { observer.finish() }

    stateObservers.removeAll()
  }

  private func removeStateObserver(_ id: UUID) {
    stateObservers[id] = nil
  }
}
