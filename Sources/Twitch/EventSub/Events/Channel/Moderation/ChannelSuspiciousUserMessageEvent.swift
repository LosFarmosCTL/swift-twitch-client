/// An EventSub notification delivered when a suspicious user sends a message.
public struct ChannelSuspiciousUserMessageEvent: Event {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String

  /// The Twitch user ID.
  public let userID: String
  /// The user’s display name.
  public let userDisplayName: String
  /// The user’s login name.
  public let userLogin: String

  /// The moderation status assigned to the suspicious user.
  /// The message is from a monitored or restricted user.
  public let lowTrustStatus: LowTrustStatus
  /// The channel IDs sharing a ban for this user.
  public let sharedBanChannelIDs: [String]
  /// The suspicious-user classifications.
  public let types: [SuspiciousUserType]
  /// Twitch’s assessment of whether the user is evading a ban.
  public let banEvasionEvaluation: BanEvasionEvaluation

  /// The message content or explanatory text supplied by Twitch.
  public let message: Message

  /// Creates a `ChannelSuspiciousUserMessageEvent` value.
  public init(
    broadcasterID: String,
    broadcasterDisplayName: String,
    broadcasterLogin: String,
    userID: String,
    userDisplayName: String,
    userLogin: String,
    lowTrustStatus: LowTrustStatus,
    sharedBanChannelIDs: [String] = [],
    types: [SuspiciousUserType] = [],
    banEvasionEvaluation: BanEvasionEvaluation,
    message: Message
  ) {
    self.broadcasterID = broadcasterID
    self.broadcasterDisplayName = broadcasterDisplayName
    self.broadcasterLogin = broadcasterLogin
    self.userID = userID
    self.userDisplayName = userDisplayName
    self.userLogin = userLogin
    self.lowTrustStatus = lowTrustStatus
    self.sharedBanChannelIDs = sharedBanChannelIDs
    self.types = types
    self.banEvasionEvaluation = banEvasionEvaluation
    self.message = message
  }

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterDisplayName = "broadcasterUserName"
    case broadcasterLogin = "broadcasterUserLogin"
    case userID = "userId"
    case userDisplayName = "userName"
    case userLogin
    case types
    case banEvasionEvaluation
    case lowTrustStatus
    case sharedBanChannelIDs = "sharedBanChannelIds"
    case message
  }

  /// The restriction or monitoring treatment applied to a suspicious user, preserving
  /// unfamiliar values in `rawValue`.
  public struct LowTrustStatus: RawRepresentable, Codable, Sendable, Hashable {
    /// The exact low-trust status string supplied by Twitch or the caller.
    public let rawValue: String

    /// Creates a low-trust status from any raw string.
    public init(rawValue: String) { self.rawValue = rawValue }

    /// Decodes a low-trust status from a single string.
    public init(from decoder: Decoder) throws {
      self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
    }

    /// Encodes this low-trust status as its raw wire string.
    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(rawValue)
    }

    /// The user has no suspicious-user treatment. Reported on suspicious user updates.
    public static let noTreatment = Self(rawValue: "no_treatment")
    /// The user is restricted from participating in chat.
    public static let restricted = Self(rawValue: "restricted")
    /// Messages from this user are monitored by moderators. Encoded as
    /// `"active_monitoring"`.
    public static let activeMonitoring = Self(rawValue: "active_monitoring")
  }

  /// The reasons Twitch or a moderator classified a user as suspicious, preserving
  /// unfamiliar values in `rawValue`.
  public struct SuspiciousUserType: RawRepresentable, Codable, Sendable, Hashable {
    /// The exact suspicious-user type string supplied by Twitch or the caller.
    public let rawValue: String

    /// Creates a suspicious-user type from any raw string.
    public init(rawValue: String) { self.rawValue = rawValue }

    /// Decodes a suspicious-user type from a single string.
    public init(from decoder: Decoder) throws {
      self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
    }

    /// Encodes this suspicious-user type as its raw wire string.
    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(rawValue)
    }

    /// A moderator manually marked the user as suspicious. Encoded as `"manually_added"`.
    public static let manuallyAdded = Self(rawValue: "manually_added")
    /// Twitch identified the user as a suspected ban evader. Encoded as `"ban_evader"`.
    public static let banEvader = Self(rawValue: "ban_evader")
    /// The user was banned in a channel sharing ban information. Encoded as
    /// `"banned_in_shared_channel"`.
    public static let bannedInSharedChannel = Self(rawValue: "banned_in_shared_channel")
  }

  /// Twitch’s confidence that the user is evading a ban, preserving unfamiliar values
  /// in `rawValue`.
  public struct BanEvasionEvaluation: RawRepresentable, Codable, Sendable, Hashable {
    /// The exact ban-evasion evaluation string supplied by Twitch or the caller.
    public let rawValue: String

    /// Creates a ban-evasion evaluation from any raw string.
    public init(rawValue: String) { self.rawValue = rawValue }

    /// Decodes a ban-evasion evaluation from a single string.
    public init(from decoder: Decoder) throws {
      self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
    }

    /// Encodes this ban-evasion evaluation as its raw wire string.
    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(rawValue)
    }

    /// Twitch has not determined a classification.
    public static let unknown = Self(rawValue: "unknown")
    /// Ban evasion is possible.
    public static let possible = Self(rawValue: "possible")
    /// Ban evasion is likely.
    public static let likely = Self(rawValue: "likely")
  }

  /// A chat message’s full text and ordered content fragments.
  public struct Message: Decodable, Sendable {
    /// The identifier assigned by Twitch.
    public let id: String
    /// The text content.
    public let text: String
    /// The ordered message fragments.
    public let fragments: [Fragment]

    /// Creates a `Message` value.
    public init(
      id: String,
      text: String,
      fragments: [Fragment] = []
    ) {
      self.id = id
      self.text = text
      self.fragments = fragments
    }

    enum CodingKeys: String, CodingKey {
      case id = "messageId"
      case text, fragments
    }

    /// A run of message text with its content type and any associated metadata.
    public struct Fragment: Decodable, Sendable {
      /// The text content.
      public let text: String
      /// The category of content represented by this fragment.
      public let type: FragmentType

      /// Creates a `Fragment` value.
      public init(
        text: String,
        type: FragmentType
      ) {
        self.text = text
        self.type = type
      }

      enum CodingKeys: String, CodingKey {
        case text, type
      }

      /// Decodes the fragment and its type-specific metadata.
      public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        text = try container.decode(String.self, forKey: .text)
        type = try FragmentType(from: decoder)
      }

      /// The content kind of a message fragment and any associated metadata.
      public enum FragmentType: Sendable {
        /// An emote message fragment with its associated metadata.
        case emote(Emote)
        /// A cheermote message fragment with its associated metadata.
        case cheermote(Cheermote)
        /// A text message fragment.
        case text
        /// An unfamiliar fragment kind. The fragment's text remains available.
        case unknown(String)

        enum CodingKeys: String, CodingKey {
          case type, emote, cheermote
        }

        init(from decoder: Decoder) throws {
          let container = try decoder.container(keyedBy: CodingKeys.self)
          let rawType = try container.decode(String.self, forKey: .type)
          guard let type = FragmentType(rawValue: rawType) else {
            self = .unknown(rawType)
            return
          }

          switch type {
          case .emote:
            self = .emote(try container.decode(Emote.self, forKey: .emote))
          case .cheermote:
            self = .cheermote(try container.decode(Cheermote.self, forKey: .cheermote))
          case .text:
            self = .text
          }
        }

        private enum FragmentType: String {
          case emote, cheermote, text
        }
      }

      /// Emote metadata for a fragment of the chat message.
      public struct Emote: Decodable, Sendable {
        /// The identifier assigned by Twitch.
        public let id: String
        /// The identifier of the set.
        public let setID: String

        /// Creates an `Emote` value.
        public init(
          id: String,
          setID: String
        ) {
          self.id = id
          self.setID = setID
        }

        enum CodingKeys: String, CodingKey {
          case id
          case setID = "emoteSetId"
        }
      }

      /// A Cheermote’s prefix, Bits amount, and contribution tier.
      public struct Cheermote: Decodable, Sendable {
        /// The prefix used to identify the Cheermote in chat.
        public let prefix: String
        /// The number of Bits.
        public let bits: Int
        /// The Cheermote tier.
        public let tier: Int

        /// Creates a `Cheermote` value.
        public init(
          prefix: String,
          bits: Int,
          tier: Int
        ) {
          self.prefix = prefix
          self.bits = bits
          self.tier = tier
        }
      }
    }
  }
}
