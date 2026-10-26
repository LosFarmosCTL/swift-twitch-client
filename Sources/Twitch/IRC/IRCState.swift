import Foundation
import TwitchIRC

/// A snapshot of session connectivity, channel membership, and recovery progress.
public struct IRCState: Sendable {
  /// The IRC session’s connection, recovery, or terminal state.
  public enum Status: Sendable, Equatable {
    /// The session has not started connecting.
    case idle
    /// The session is establishing its initial connections.
    case connecting
    /// The session’s connections are ready.
    case connected
    /// The session is recovering one or more connections.
    case reconnecting
    /// The session has permanently shut down.
    case shutdown
    /// The session or channel has failed; carries the failure reason.
    case failed(IRCChannelFailure)
  }

  /// The IRC session’s connection lifecycle state.
  public internal(set) var status: Status = .idle
  /// The desired channel login names mapped to their current membership states.
  public internal(set) var channels: [String: IRCChannelStatus] = [:]
  /// The connection recovery operations currently in progress.
  public internal(set) var recoveries: [IRCRecovery] = []
  /// The latest account-wide IRC user state received from Twitch, when provided.
  public internal(set) var globalUserState: GlobalUserState?
}

/// An in-progress recovery operation for an IRC connection.
public struct IRCRecovery: Sendable, Equatable {
  /// Whether the recovering connection receives chat or sends messages.
  public enum Role: Sendable, Equatable {
    /// A connection used to receive channel messages.
    case read
    /// The connection used to send messages.
    case write
  }

  /// The server request or connection failure that triggered recovery.
  public enum Reason: Sendable, Equatable {
    /// Twitch requested a replacement connection.
    case serverRequestedReconnect
    /// The connection closed unexpectedly.
    case connectionClosed
    /// The connection did not complete its handshake before the deadline.
    case handshakeTimedOut
    /// The connection failed; carries a diagnostic description.
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

  /// The identifier of the connection being recovered.
  public let connectionID: UUID
  /// The role of the connection being recovered.
  public let role: Role
  /// The channels affected by this connection recovery.
  public internal(set) var channels: Set<String>
  /// The reason supplied for this action.
  public let reason: Reason

  /// The recovery attempt number.
  public let attempt: Int
  /// The scheduled retry time, or `nil` while establishing the replacement connection.
  public internal(set) var retryAt: Date?
}
