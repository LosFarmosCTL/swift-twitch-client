import Foundation
import TwitchIRC

extension IRCConnectionPool {
  private static let maxChannels = 90

  func join(to channel: String) throws {
    guard !state.ended else { throw IRCError.disconnected }

    let channel = IRCWireMessage.channelLogin(channel)

    guard state.statuses[channel] == nil else { return }

    let id = updateState { state in
      let id =
        state.entries.first(where: { $0.value.channels.count < Self.maxChannels })?.key
        ?? addEntry(to: &state)

      state.entries[id]?.channels.insert(channel)
      state.statuses[channel] =
        if state.entries[id]?.recovery == nil { .joining } else { .reconnecting }

      return id
    }

    if state.entries[id]?.ready == true {
      scheduleJoin(channel, id: id)
    } else if state.active, state.entries[id]?.task == nil {
      startRelay(id)
    }
  }

  func retryChannel(_ channel: String) throws {
    guard !state.ended else { throw IRCError.disconnected }

    let channel = IRCWireMessage.channelLogin(channel)

    let id = state.entries.first(where: { $0.value.channels.contains(channel) })?.key
    guard case .failed = state.statuses[channel], let id else { return }

    updateState { state in
      state.statuses[channel] =
        if state.entries[id]?.recovery == nil { .joining } else { .reconnecting }
    }

    if state.entries[id]?.ready == true {
      scheduleJoin(channel, id: id)
    }
  }

  func part(from channel: String) throws {
    guard !state.ended else { throw IRCError.disconnected }

    let channel = IRCWireMessage.channelLogin(channel)

    let id = state.entries.first(where: { $0.value.channels.contains(channel) })?.key
    guard let id else { return }

    cancelJoin(channel)

    let retired: Entry? = updateState { state in
      state.entries[id]?.channels.remove(channel)
      state.statuses[channel] = nil

      return if state.entries[id]?.channels.isEmpty == true {
        state.removeEntry(id)
      } else { nil }
    }

    if let retired {
      retired.task?.cancel()

      Task { await retired.supervisor.disconnect() }
    } else if state.entries[id]?.ready == true {
      Task { await self.sendPart(channel, id: id) }
    }
  }

  private func sendPart(_ channel: String, id: UUID) async {
    guard let entry = state.entries[id] else { return }
    guard !entry.channels.contains(channel) else { return }

    try? await entry.supervisor.send(.part(from: channel))
  }
}
