import Foundation
import MemberwiseInit

/// An EventSub notification delivered when a viewer redeems an automatic Channel Points
/// reward.
@MemberwiseInit(.public)
public struct ChannelPointsAutomaticRewardRedemptionAddEvent: Event {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The user’s display name.
  public let userDisplayName: String

  /// The identifier assigned by Twitch.
  public let id: String
  /// The reward details.
  public let reward: Reward
  /// The message content or explanatory text supplied by Twitch.
  public let message: Message
  /// The time the reward was redeemed.
  public let redeemedAt: Date

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case id
    case reward
    case message
    case redeemedAt
  }

  /// The automatic reward’s type, Channel Points cost, and any unlocked emote.
  @MemberwiseInit(.public)
  public struct Reward: Decodable, Sendable {
    /// The automatic reward redeemed by the viewer.
    public let type: RewardType
    /// The number of Channel Points.
    public let channelPoints: Int
    /// The emote details, when provided.
    public let emote: Emote?

    /// Emote metadata for a fragment of the chat message.
    public struct Emote: Decodable, Sendable {
      /// The identifier assigned by Twitch.
      public let id: String
    }

    /// The built-in Channel Points reward redeemed by the viewer.
    public enum RewardType: String, Decodable, Sendable {
      /// Allows one message to bypass subscriber-only chat. Encoded as
      /// `"single_message_bypass_sub_mode"`.
      case singleMessageBypassSubMode = "single_message_bypass_sub_mode"
      /// Highlights the redeemed chat message. Encoded as `"send_highlighted_message"`.
      case sendHighlightedMessage = "send_highlighted_message"
      /// Unlocks a random subscriber emote. Encoded as `"random_sub_emote_unlock"`.
      case randomSubEmoteUnlock = "random_sub_emote_unlock"
      /// Unlocks the subscriber emote chosen by the viewer. Encoded as
      /// `"chosen_sub_emote_unlock"`.
      case chosenSubEmoteUnlock = "chosen_sub_emote_unlock"
      /// Unlocks a modified version of a chosen subscriber emote. Encoded as
      /// `"chosen_modified_sub_emote_unlock"`.
      case chosenModifiedSubEmoteUnlock = "chosen_modified_sub_emote_unlock"
    }
  }

  /// A chat message’s full text and ordered content fragments.
  @MemberwiseInit(.public)
  public struct Message: Decodable, Sendable {
    /// The text content.
    public let text: String
    /// The ordered message fragments.
    public let fragments: [Fragment]

    /// A run of message text with its content type and any associated metadata.
    @MemberwiseInit(.public)
    public struct Fragment: Decodable, Sendable {
      /// The category of content represented by this fragment.
      public let type: FragmentType
      /// The text content.
      public let text: String
      /// The emote details, when provided.
      public let emote: Emote?

      enum CodingKeys: String, CodingKey {
        case type
        case text
        case emote
      }

      /// Decodes the fragment and its type-specific metadata.
      public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        text = try container.decode(String.self, forKey: .text)
        emote = try container.decodeIfPresent(Emote.self, forKey: .emote)
        type = try container.decode(FragmentType.self, forKey: .type)
      }

      /// The content kind of a message fragment and any associated metadata.
      public enum FragmentType: String, Decodable, Sendable {
        /// A text message fragment.
        case text
        /// An emote message fragment.
        case emote
      }

      /// Emote metadata for a fragment of the chat message.
      @MemberwiseInit(.public)
      public struct Emote: Decodable, Sendable {
        /// The identifier assigned by Twitch.
        public let id: String
      }
    }
  }
}
