import Foundation
public import TwitchIRC

/// A diagnostic snapshot of an IRC transport's connectivity, channels, and recovery state.
///
/// Exposed via ``ChatState/ircReader`` and ``ChatState/ircWriter`` when IRC is configured
/// as the managed chat reader or writer.
///
/// - SeeAlso: <doc:ManagedChat>, ``ChatState``, ``IRCRecovery``, ``IRCChannelStatus``
public struct IRCState: Sendable {
  /// The connection lifecycle state of an IRC reader pool or writer session.
  public enum Status: Sendable, Equatable {
    /// No connection has been started yet.
    case idle
    /// Initial connections are performing the IRC WebSocket handshake and login.
    case connecting
    /// All active connections are established and ready.
    case connected
    /// One or more connections are undergoing automatic recovery (see ``IRCState/recoveries``).
    case reconnecting
    /// The IRC transport has permanently shut down.
    case shutdown
    /// The transport failed terminally (for example, authentication failed).
    case failed(IRCChannelFailure)
  }

  /// The overall lifecycle status of this IRC transport.
  public internal(set) var status: Status = .idle
  /// Desired channel logins (lowercase, without `#`) mapped to their current IRC join status.
  public internal(set) var channels: [String: IRCChannelStatus] = [:]
  /// Active connection recovery operations currently in progress.
  public internal(set) var recoveries: [IRCRecovery] = []
  /// The latest `GLOBALUSERSTATE` received from Twitch on this transport, if authenticated.
  public internal(set) var globalUserState: GlobalUserState?

  /// Creates an `IRCState` value.
  public init(
    status: Status = .idle,
    channels: [String: IRCChannelStatus] = [:],
    recoveries: [IRCRecovery] = [],
    globalUserState: GlobalUserState? = nil
  ) {
    self.status = status
    self.channels = channels
    self.recoveries = recoveries
    self.globalUserState = globalUserState
  }
}

/// Details of an in-progress recovery for a single IRC WebSocket connection.
///
/// - SeeAlso: ``IRCState/recoveries``, <doc:ManagedChat>
public struct IRCRecovery: Sendable, Equatable {
  /// Whether an IRC connection belongs to the read pool or the dedicated write transport.
  public enum Role: Sendable, Equatable {
    /// A pooled connection used to join channels and receive chat messages.
    case read
    /// The dedicated authenticated connection used to send outgoing IRC commands.
    case write
  }

  /// The server signal or transport failure that triggered connection recovery.
  public enum Reason: Sendable, Equatable {
    /// Twitch sent an IRC `RECONNECT` command requesting a replacement connection.
    case serverRequestedReconnect
    /// The WebSocket closed unexpectedly.
    case connectionClosed
    /// The IRC login and capability handshake did not complete before the deadline.
    case handshakeTimedOut
    /// The WebSocket transport failed; carries a diagnostic description of the error.
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

  /// The local identifier of the connection being replaced.
  public let connectionID: UUID
  /// Whether the recovering connection is a reader or writer.
  public let role: Role
  /// The channel logins hosted by this connection that are being rejoined.
  public internal(set) var channels: Set<String>
  /// The event or failure that triggered this recovery.
  public let reason: Reason

  /// The 1-based retry attempt counter for this recovery sequence.
  public let attempt: Int
  /// When the next reconnect attempt is scheduled, or `nil` while an attempt is actively connecting.
  public internal(set) var retryAt: Date?

  /// Creates an `IRCRecovery` value.
  public init(
    connectionID: UUID,
    role: Role,
    channels: Set<String> = [],
    reason: Reason,
    attempt: Int,
    retryAt: Date? = nil
  ) {
    self.connectionID = connectionID
    self.role = role
    self.channels = channels
    self.reason = reason
    self.attempt = attempt
    self.retryAt = retryAt
  }
}
