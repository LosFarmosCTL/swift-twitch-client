public struct ChannelSubscriptionMessageEvent: Event {
  public let userID: String
  public let userLogin: String
  public let userName: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let tier: String
  public let durationMonths: Int
  public let cumulativeMonths: Int
  public let streakMonths: Int?

  public let message: Message

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin, userName

    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"

    case tier, cumulativeMonths, streakMonths, durationMonths
    case message
  }

  public struct Message: Decodable, Sendable {
    public let text: String
    public let emotes: [Emote]

    public struct Emote: Decodable, Sendable {
      public let begin: Int
      public let end: Int
      public let id: String
    }
  }
}
