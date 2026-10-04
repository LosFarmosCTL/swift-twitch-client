import Foundation
import TwitchIRC

public struct IRCState: Sendable {
  public enum Status: Sendable, Equatable {
    case idle
    case connecting
    case connected
    case reconnecting
    case shutdown
    case failed(IRCChannelFailure)
  }

  public internal(set) var status: Status = .idle
  public internal(set) var channels: [String: IRCChannelStatus] = [:]
  public internal(set) var recoveries: [IRCRecovery] = []
  public internal(set) var globalUserState: GlobalUserState?
}

public struct IRCRecovery: Sendable, Equatable {
  public enum Role: Sendable, Equatable {
    case read
    case write
  }

  public enum Reason: Sendable, Equatable {
    case serverRequestedReconnect
    case connectionClosed
    case handshakeTimedOut
    case connectionFailed(String)

    internal init(error: Error) {
      switch error {
      case IRCError.handshakeTimedOut:
        self = .handshakeTimedOut
      default:
        self = .connectionFailed(String(describing: error))
      }
    }
  }

  public let connectionID: UUID
  public let role: Role
  public internal(set) var channels: Set<String>
  public let reason: Reason

  public let attempt: Int
  public internal(set) var retryAt: Date?
}
