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
        case .state(let snapshot): connectionStateChanged(snapshot, id: id)
        case .message(let message): await handle(message, id: id)
        }
      }
    } catch {
      guard state.entries[id] != nil else { return }

      await disconnect(throwing: error)
    }
  }

  private func connectionStateChanged(_ snapshot: IRCState, id: UUID) {
    guard let entry = state.entries[id] else { return }

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

          if state.channels[channel]?.status.isFailed == true { continue }

          state.channels[channel]?.status = .reconnecting
        }
      }
    }

    if snapshot.status == .connected, !entry.ready { rejoinChannels(id) }
  }

  private func rejoinChannels(_ id: UUID) {
    batchStateUpdates {
      for channel in state.entries[id]?.channels ?? [] {
        if state.channels[channel]?.status.isFailed == true { continue }

        scheduleJoin(channel, id: id)
      }
    }
  }
}
