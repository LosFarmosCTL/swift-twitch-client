import MemberwiseInit

/// An EventSub notification delivered when a suspicious user sends a message.
@MemberwiseInit(.public)
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
  public let lowTrustStatus: LowTrustStatus
  /// The channel IDs sharing a ban for this user.
  public let sharedBanChannelIDs: [String]
  /// The suspicious-user classifications.
  public let types: [SuspiciousUserType]
  /// Twitch’s assessment of whether the user is evading a ban.
  public let banEvasionEvaluation: BanEvasionEvaluation

  /// The message content or explanatory text supplied by Twitch.
  public let message: Message

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

  /// The restriction or monitoring treatment applied to a suspicious user.
  public enum LowTrustStatus: String, Codable, Sendable {
    /// No classification or restriction applies.
    case none
    /// The user is restricted from participating in chat.
    case restricted
    /// Messages from this user are monitored by moderators. Encoded as
    /// `"active_monitoring"`.
    case activeMonitoring = "active_monitoring"
  }

  /// The reasons Twitch or a moderator classified a user as suspicious.
  public enum SuspiciousUserType: String, Codable, Sendable {
    /// A moderator manually marked the user as suspicious. Encoded as `"manually_added"`.
    case manuallyAdded = "manually_added"
    /// Twitch identified the user as a suspected ban evader. Encoded as `"ban_evader"`.
    case banEvader = "ban_evader"
    /// The user was banned in a channel sharing ban information. Encoded as
    /// `"banned_in_shared_channel"`.
    case bannedInSharedChannel = "banned_in_shared_channel"
  }

  /// Twitch’s confidence that the user is evading a ban.
  public enum BanEvasionEvaluation: String, Codable, Sendable {
    /// Twitch has not determined a classification.
    case unknown
    /// Ban evasion is possible.
    case possible
    /// Ban evasion is likely.
    case likely
  }

  /// A chat message’s full text and ordered content fragments.
  @MemberwiseInit(.public)
  public struct Message: Decodable, Sendable {
    /// The identifier assigned by Twitch.
    public let id: String
    /// The text content.
    public let text: String
    /// The ordered message fragments.
    public let fragments: [Fragment]

    enum CodingKeys: String, CodingKey {
      case id = "messageId"
      case text, fragments
    }

    /// A run of message text with its content type and any associated metadata.
    @MemberwiseInit(.public)
    public struct Fragment: Decodable, Sendable {
      /// The text content.
      public let text: String
      /// The category of content represented by this fragment.
      public let type: FragmentType

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

        enum CodingKeys: String, CodingKey {
          case type, emote, cheermote
        }

        init(from decoder: Decoder) throws {
          let container = try decoder.container(keyedBy: CodingKeys.self)
          let type = try container.decode(FragmentType.self, forKey: .type)

          switch type {
          case .emote:
            self = .emote(try container.decode(Emote.self, forKey: .emote))
          case .cheermote:
            self = .cheermote(try container.decode(Cheermote.self, forKey: .cheermote))
          case .text:
            self = .text
          }
        }

        private enum FragmentType: String, Decodable, Sendable {
          case emote, cheermote, text
        }
      }

      /// Emote metadata for a fragment of the chat message.
      @MemberwiseInit(.public)
      public struct Emote: Decodable, Sendable {
        /// The identifier assigned by Twitch.
        public let id: String
        /// The identifier of the set.
        public let setID: String

        enum CodingKeys: String, CodingKey {
          case id
          case setID = "emoteSetId"
        }
      }

      /// A Cheermote’s prefix, Bits amount, and contribution tier.
      @MemberwiseInit(.public)
      public struct Cheermote: Decodable, Sendable {
        /// The prefix used to identify the Cheermote in chat.
        public let prefix: String
        /// The number of Bits.
        public let bits: Int
        /// The Cheermote tier.
        public let tier: Int
      }
    }
  }
}
