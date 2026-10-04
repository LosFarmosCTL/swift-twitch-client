import Foundation
import TwitchIRC

extension IRCConnectionPool {
  private static let maxChannels = 90

  func setChannels(_ channels: [String]) throws {
    guard !state.ended else { throw IRCError.disconnected }

    let desired = Set(channels.map(normalize))

    for channel in Set(state.statuses.keys).subtracting(desired) {
      try part(from: channel)
    }

    for channel in desired.subtracting(state.statuses.keys) {
      try join(to: channel)
    }
  }

  func join(to channel: String) throws {
    guard !state.ended else { throw IRCError.disconnected }

    let channel = normalize(channel)

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

    let channel = normalize(channel)

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

    let channel = normalize(channel)

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

extension IRCConnectionPool {
  func scheduleJoin(_ channel: String, id: UUID) {
    guard state.entries[id]?.ready == true else { return }
    guard pendingJoins[channel] == nil else { return }

    let token = UUID()

    let task = Task<Void, Never> { [weak self] in
      await self?.sendJoin(channel, id: id, token: token)
    }

    pendingJoins[channel] = PendingJoin(token: token, task: task)
    updateState { $0.statuses[channel] = .joining }
  }

  private func sendJoin(_ channel: String, id: UUID, token: UUID) async {
    guard let supervisor = state.entries[id]?.supervisor else { return }

    do {
      if let credentials {
        try await rateLimiter.acquire(account: credentials.userID, operation: .join)
      }

      guard state.entries[id]?.ready == true else { return }
      guard pendingJoins[channel]?.token == token else { return }

      try await supervisor.send(.join(to: channel))

      guard pendingJoins[channel]?.token == token else { return }

      try await Task.sleep(for: joinTimeout)
      joinExpired(channel, id: id, token: token)
    } catch {
      // The supervisor handles socket failures, cancellation ends the JOIN wait.
      return
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
    updateState { $0.statuses[channel] = .failed(.joinTimedOut) }
  }

  private func joined(_ channel: String) {
    cancelJoin(channel)
    updateState { $0.statuses[channel] = .joined }
  }

  func handle(_ message: IncomingMessage, id: UUID) async {
    guard let entry = state.entries[id] else { return }

    let login = credentials?.userLogin.lowercased() ?? "justinfan12345"

    switch message {
    case .join(let join) where join.userLogin == login:
      if entry.channels.contains(join.channel) {
        joined(join.channel)
      } else {
        try? await entry.supervisor.send(.part(from: join.channel))
      }

    case .roomState(let room) where entry.channels.contains(room.channel):
      joined(room.channel)

    case .part(let part) where part.userLogin == login:
      if entry.channels.contains(part.channel) {
        cancelJoin(part.channel)
        scheduleJoin(part.channel, id: id)
      }

    case .notice(let notice):
      handleJoinNotice(notice, id: id)

    default: break
    }

    if state.entries[id] != nil { continuation?.yield(message) }
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
      $0.statuses[channel] = .failed(.joinRejected(code: identifier, message: message))
    }
  }

  func normalize(_ channel: String) -> String {
    String(channel.drop(while: { $0 == "#" })).lowercased()
  }
}
