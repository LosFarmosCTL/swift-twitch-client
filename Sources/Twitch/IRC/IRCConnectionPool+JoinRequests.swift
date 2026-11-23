import Foundation
import TwitchIRC

extension IRCConnectionPool {
  struct PendingJoin {
    let token: UUID
    let task: Task<Void, Never>
  }

  func scheduleJoin(_ channel: String, id: UUID) {
    guard state.entries[id]?.ready == true else { return }
    guard pendingJoins[channel] == nil else { return }

    let token = UUID()

    let task = Task<Void, Never> { [weak self] in
      await self?.sendJoin(channel, id: id, token: token)
    }

    pendingJoins[channel] = PendingJoin(token: token, task: task)
    updateState { $0.channels[channel]?.status = .joining }
  }

  private func sendJoin(_ channel: String, id: UUID, token: UUID) async {
    defer {
      if pendingJoins[channel]?.token == token {
        pendingJoins.removeValue(forKey: channel)
      }
    }

    guard let supervisor = state.entries[id]?.supervisor else { return }

    do {
      if let credentials {
        try await rateLimiter.acquire(
          account: try credentials.requireUser().id, operation: .join)
      }

      guard state.entries[id]?.ready == true else { return }
      guard pendingJoins[channel]?.token == token else { return }

      try await supervisor.send(.join(to: channel))

      guard pendingJoins[channel]?.token == token else { return }

      try await Task.sleep(for: joinTimeout)
      joinExpired(channel, id: id, token: token)
    } catch {
      handleJoinSendFailure(error, channel: channel, id: id, token: token)
    }
  }

  private func handleJoinSendFailure(
    _ error: any Error, channel: String, id: UUID, token: UUID
  ) {
    guard !Task.isCancelled else { return }
    guard pendingJoins[channel]?.token == token,
      state.entries[id]?.channels.contains(channel) == true
    else { return }

    switch error {
    case IRCError.invalidInput, IRCError.loginFailed, IRCError.capabilitiesRejected,
      is TwitchAuthenticationError:
      updateState { $0.channels[channel]?.status = .failed(.init(terminalError: error)) }
    default:
      // Transient send failures trigger supervisor recovery; keep the channel eligible for rejoin.
      updateState { $0.channels[channel]?.status = .reconnecting }
    }
  }

  func cancelJoin(_ channel: String) {
    let pending = pendingJoins.removeValue(forKey: channel)
    pending?.task.cancel()
  }

  private func joinExpired(_ channel: String, id: UUID, token: UUID) {
    guard state.entries[id]?.channels.contains(channel) == true else { return }
    guard pendingJoins[channel]?.token == token else { return }

    cancelJoin(channel)
    updateState { $0.channels[channel]?.status = .failed(.joinTimedOut) }
  }

  private func markJoined(_ channel: String) {
    cancelJoin(channel)
    guard state.channels[channel]?.status != .joined else { return }
    updateState { $0.channels[channel]?.status = .joined }
  }

  func handle(_ message: IncomingMessage, id: UUID) async {
    guard let entry = state.entries[id] else { return }

    let login = IRCWireMessage.login(for: credentials)

    switch message {
    case .join(let join) where join.userLogin == login:
      await handleSelfJoin(join, entry: entry)

    case .roomState(let room) where entry.channels.contains(room.channel):
      await handleRoomState(room, on: entry.supervisor)

    case .part(let part) where part.userLogin == login:
      handleSelfPart(part, entry: entry, id: id)

    case .notice(let notice):
      handleJoinNotice(notice, id: id)

    default: break
    }

    guard state.entries[id] != nil else { return }
    updates?.yield(.message(message))
  }

  private func handleSelfJoin(_ join: Join, entry: Entry) async {
    guard entry.channels.contains(join.channel) else {
      try? await entry.supervisor.send(.part(from: join.channel))
      return
    }
    guard let channelState = state.channels[join.channel],
      channelState.expectedRoomID == nil,
      !channelState.status.isFailed
    else { return }

    markJoined(join.channel)
  }

  private func handleSelfPart(_ part: Part, entry: Entry, id: UUID) {
    guard entry.channels.contains(part.channel),
      let channelState = state.channels[part.channel],
      !channelState.status.isFailed
    else { return }

    cancelJoin(part.channel)
    scheduleJoin(part.channel, id: id)
  }

  private func handleRoomState(_ room: RoomState, on supervisor: IRCConnectionSupervisor) async {
    guard let channelState = state.channels[room.channel] else { return }

    guard let expected = channelState.expectedRoomID else {
      guard !channelState.status.isFailed else { return }
      markJoined(room.channel)
      return
    }

    guard !room.roomID.isEmpty,
      pendingJoins[room.channel] != nil || channelState.status == .joined
    else { return }

    guard room.roomID != expected else {
      markJoined(room.channel)
      return
    }

    cancelJoin(room.channel)
    let message = "#\(room.channel) has room ID \(room.roomID), expected \(expected)."
    updateState { $0.channels[room.channel]?.status = .failed(.connectionFailed(message)) }
    try? await supervisor.send(.part(from: room.channel))
  }

  private func handleJoinNotice(_ notice: Notice, id: UUID) {
    guard case .local(let channel, let message, let code) = notice.kind else { return }
    guard state.entries[id]?.channels.contains(channel) == true else { return }
    guard [.msgChannelSuspended, .msgRoomNotFound].contains(code) else { return }

    cancelJoin(channel)

    let identifier =
      if code == .msgChannelSuspended {
        "msg_channel_suspended"
      } else {
        "msg_room_not_found"
      }

    updateState {
      $0.channels[channel]?.status = .failed(.joinRejected(code: identifier, message: message))
    }
  }
}
