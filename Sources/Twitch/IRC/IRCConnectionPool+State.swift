import Foundation
import TwitchIRC

extension IRCConnectionPool {
  struct ChannelTarget: Hashable, Sendable {
    let login: String
    let expectedRoomID: String?
    let token: UUID?

    init(login: String, expectedRoomID: String? = nil, token: UUID? = nil) {
      self.login = IRCWireMessage.channelLogin(login)
      self.expectedRoomID = expectedRoomID
      self.token = token
    }
  }

  struct ChannelState: Sendable, Equatable {
    var status: IRCChannelStatus
    var expectedRoomID: String?
    var token: UUID?
  }

  struct PoolState: Sendable {
    let ircState: IRCState
    let channels: [String: ChannelState]
  }

  enum Update: Sendable {
    case state(PoolState)
    case message(IncomingMessage)
  }

  struct Entry: Sendable {
    let supervisor: IRCConnectionSupervisor

    var channels: Set<String> = []
    var ready = false
    var recovery: IRCRecovery?
    var globalUserState: GlobalUserState?
    var task: Task<Void, Never>?
  }

  struct State: Sendable {
    var entries: [UUID: Entry] = [:]
    var active = false
    var ended = false
    var terminalError: Error?
    var globalUserState: GlobalUserState?
    var userStateConnectionID: UUID?
    var channels: [String: ChannelState] = [:]
  }

  var snapshot: IRCState { state.snapshot }
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

  var poolState: IRCConnectionPool.PoolState {
    IRCConnectionPool.PoolState(ircState: snapshot, channels: channels)
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
    } else if !active || entries.isEmpty {
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
      channels: channels.mapValues(\.status),
      recoveries: recoveries,
      globalUserState: globalUserState)
  }
}
