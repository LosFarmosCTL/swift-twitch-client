import Foundation

public struct ChannelPointsAutomaticRewardRedemptionAddEvent: Event {
  let broadcasterID: String
  let broadcasterLogin: String
  let broadcasterName: String

  let userID: String
  let userLogin: String
  let userName: String

  let id: String
  let reward: Reward
  let message: Message
  let redeemedAt: Date

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"

    case userID = "userId"
    case userLogin, userName

    case id, reward, message, redeemedAt
  }

  public struct Reward: Decodable, Sendable {
    let type: RewardType
    let channelPoints: Int
    let emote: Emote?

    public struct Emote: Decodable, Sendable {
      let id: Int
      let name: String
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
    let text: String
    let emote: Emote?

    public struct Emote: Decodable, Sendable {
      let id: String
    }
  }
}
