import Foundation

public struct ChannelPointsAutomaticRewardRedemptionAddEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let userID: String
  public let userLogin: String
  public let userName: String

  public let id: String
  public let reward: Reward
  public let message: Message
  public let redeemedAt: Date

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"

    case userID = "userId"
    case userLogin, userName

    case id, reward, message, redeemedAt
  }

  public struct Reward: Decodable, Sendable {
    public let type: RewardType
    public let channelPoints: Int
    public let emote: Emote?

    public struct Emote: Decodable, Sendable {
      public let id: String
    }

    public enum RewardType: String, Decodable, Sendable {
      case singleMessageBypassSubMode = "single_message_bypass_sub_mode"
      case sendHighlightedMessage = "send_highlighted_message"
      case randomSubEmoteUnlock = "random_sub_emote_unlock"
      case chosenSubEmoteUnlock = "chosen_sub_emote_unlock"
      case chosenModifiedSubEmoteUnlock = "chosen_modified_sub_emote_unlock"
    }
  }

  public struct Message: Decodable, Sendable {
    public let text: String
    public let fragments: [Fragment]

    public struct Fragment: Decodable, Sendable {
      public let type: FragmentType
      public let text: String
      public let emote: Emote?

      enum CodingKeys: String, CodingKey {
        case type
        case text
        case emote
      }

      public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        text = try container.decode(String.self, forKey: .text)
        emote = try container.decodeIfPresent(Emote.self, forKey: .emote)
        type = try container.decode(FragmentType.self, forKey: .type)
      }

      public enum FragmentType: String, Decodable, Sendable {
        case text
        case emote
      }

      public struct Emote: Decodable, Sendable {
        public let id: String
      }
    }
  }
}
