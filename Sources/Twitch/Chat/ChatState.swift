import Foundation

public struct ChatChannel: Sendable, Equatable, Hashable {
  public let id: String
  public let login: String

  public init(id: String, login: String) {
    self.id = id
    self.login = IRCWireMessage.channelLogin(login)
  }

  internal var isValidForManagedChat: Bool {
    !id.isEmpty && !id.contains(where: { $0.isWhitespace || $0 == "\0" })
      && IRCWireMessage.isLogin(login)
  }
}

public enum ChatComponentStatus: Sendable, Equatable {
  case idle
  case connecting
  case ready
  case reconnecting
  case unavailable(String)
  case failed(String)
}

/// Unknown is deliberately distinct from a positively observed ordinary chatter.
public struct ChatPrivilege: Sendable, Equatable {
  public var isBroadcaster: Bool
  public var isModerator: Bool
  public var isVIP: Bool
  public var isKnown: Bool
  public var isPrivileged: Bool { isBroadcaster || isModerator || isVIP }

  public init(
    isBroadcaster: Bool = false, isModerator: Bool = false,
    isVIP: Bool = false, isKnown: Bool = true
  ) {
    self.isBroadcaster = isBroadcaster
    self.isModerator = isModerator
    self.isVIP = isVIP
    self.isKnown = isKnown
  }

  public static let unknown = Self(isKnown: false)
}

public struct ChatRoomSettings: Sendable, Equatable {
  public var emoteOnly: Bool?
  public var subscribersOnly: Bool?
  public var uniqueMessages: Bool?
  /// `nil` means disabled or not yet known; consult isKnown for a complete snapshot.
  public var followersOnly: Duration?
  public var slowMode: Duration?
  public var isKnown = false
}

public struct ChatChannelState: Sendable, Equatable {
  public let channel: ChatChannel
  public internal(set) var status: ChatComponentStatus = .connecting
  public internal(set) var settings = ChatRoomSettings()
  public internal(set) var privilege: ChatPrivilege = .unknown
  public internal(set) var moderation: ChatComponentStatus = .idle
  public internal(set) var moderationRevocation: EventSubRevocation.Status?
  public internal(set) var sending: ChatSendEligibility = .eligible
}

public struct ChatCredentialChange: Sendable, Equatable {
  public let revision: UInt64
  public let previousUserID: String?
  public let userID: String?
  public let behavior: ChatCredentialSwitchBehavior
  public let anonymousReaderPreserved: Bool
}

public struct ChatDeparture: Sendable, Equatable {
  public enum Reason: Sendable, Equatable {
    case requested
    case credentialsChanged
    case subscriptionRevoked(EventSubRevocation.Status)
    case requiredSubscriptionEnded(String)
    case shutdown
  }

  public let channel: ChatChannel
  public let reason: Reason
}

/// Every update carries its credential context. Observing never starts a transport.
public struct ChatState: Sendable {
  public internal(set) var credentialRevision: UInt64 = 0
  public internal(set) var userID: String?
  public internal(set) var credentialChange: ChatCredentialChange?
  public internal(set) var reader: ChatComponentStatus = .idle
  public internal(set) var writer: ChatComponentStatus = .idle
  /// Transport diagnostics, without merging independent read and write connections.
  public internal(set) var ircReader: IRCState?
  public internal(set) var ircWriter: IRCState?
  public internal(set) var channels: [String: ChatChannelState] = [:]
  public internal(set) var lastDeparture: ChatDeparture?
  public internal(set) var sendEligibility: [String: ChatSendEligibility] = [:]
  public internal(set) var isShutdown = false
}

public enum ChatError: Error, Sendable, Equatable {
  case invalidChannel
  case channelNotFound
  case parted
  case credentialsChanged
  case setupFailed(String)
  case shutdown
}

public enum ChatSendEligibility: Sendable, Equatable {
  /// Local evidence allows a send; Twitch or another sender can still reject it.
  case eligible
  case channelCooldown(until: Date)
  case accountWindow(until: Date)
  case banned
  /// An observed timeout; `nil` means its expiration was unavailable.
  case timedOut(until: Date?)
  case unavailable(String)
}

public enum ChatSendOutcome: Sendable, Equatable {
  case accepted(messageID: String)
  /// A successful IRC write is not confirmation of delivery.
  case written(clientNonce: String?)
  case rejected(code: String?, message: String)
  /// Twitch supplies no trustworthy chat-restriction expiry in Helix bucket headers.
  case rateLimited
  case failed(String)
}

public enum ChatSendError: Error, Sendable, Equatable {
  case invalidMessage
  case refused(ChatSendEligibility)
  case rejected(code: String?, message: String)
  case unsupportedClientNonce
}
