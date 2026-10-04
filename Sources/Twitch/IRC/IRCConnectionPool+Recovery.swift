import Foundation
import TwitchIRC

extension IRCConnectionPool {
  func startRelay(_ id: UUID) {
    let task = Task<Void, Never> { [weak self] in await self?.relay(id) }

    updateState { $0.entries[id]?.task = task }
  }

  private func relay(_ id: UUID) async {
    guard let supervisor = state.entries[id]?.supervisor else { return }

    do {
      let events = try await supervisor.start()

      guard state.entries[id] != nil else {
        return await supervisor.disconnect()
      }

      for try await event in events {
        guard state.entries[id] != nil else { return }

        switch event {
        case .state(let snapshot): await connectionStateChanged(snapshot, id: id)
        case .message(let message): await handle(message, id: id)
        }
      }
    } catch {
      guard state.entries[id] != nil else { return }

      await disconnect(throwing: error)
    }
  }

  private func connectionStateChanged(_ snapshot: IRCState, id: UUID) async {
    guard let entry = state.entries[id] else { return }

    if snapshot.status == .reconnecting, entry.channels.isEmpty, established {
      return await retire(id)
    }

    updateState { state in
      state.entries[id]?.globalUserState = snapshot.globalUserState
      state.entries[id]?.ready = snapshot.status == .connected
      state.entries[id]?.recovery = snapshot.recoveries.first

      if state.userStateConnectionID == id, let userState = snapshot.globalUserState {
        state.globalUserState = userState
      }

      if snapshot.status == .reconnecting {
        for channel in entry.channels {
          cancelJoin(channel)

          if case .failed = state.statuses[channel] { continue }

          state.statuses[channel] = .reconnecting
        }
      }
    }

    if snapshot.status == .connected, !entry.ready { rejoinChannels(id) }
  }

  private func rejoinChannels(_ id: UUID) {
    for channel in state.entries[id]?.channels ?? [] {
      if case .failed = state.statuses[channel] { continue }

      scheduleJoin(channel, id: id)
    }
  }

  private func retire(_ id: UUID) async {
    guard let entry = updateState({ $0.removeEntry(id) }) else { return }

    entry.task?.cancel()
    await entry.supervisor.disconnect()
  }
}
