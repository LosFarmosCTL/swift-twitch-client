import Foundation
import TwitchIRC

extension IRCConnectionPool {
  private static let maxChannels = 90

  func join(to channel: String) throws {
    try join(ChannelTarget(login: channel))
  }

  func join(_ target: ChannelTarget) throws {
    guard !state.ended else { throw IRCError.disconnected }

    let channel = target.login
    guard state.channels[channel] == nil else { return }

    let id = updateState { state in
      let id =
        state.entries.first(where: { $0.value.channels.count < Self.maxChannels })?.key
        ?? addEntry(to: &state)

      state.entries[id]?.channels.insert(channel)
      let initialStatus: IRCChannelStatus =
        state.entries[id]?.recovery == nil ? .joining : .reconnecting
      state.channels[channel] = ChannelState(
        status: initialStatus, expectedRoomID: target.expectedRoomID, token: target.token)

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
    guard state.channels[channel]?.status.isFailed == true, let id else { return }

    updateState { state in
      state.channels[channel]?.status =
        state.entries[id]?.recovery == nil ? .joining : .reconnecting
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
      state.channels[channel] = nil

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
