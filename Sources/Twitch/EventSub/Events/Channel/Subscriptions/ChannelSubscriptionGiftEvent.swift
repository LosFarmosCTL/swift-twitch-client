public struct ChannelSubscriptionGiftEvent: Event {
  public let gifter: Gifter?

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let total: Int
  public let cumulativeTotal: Int?

  public let tier: String

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin, userName

    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"
    case total, cumulativeTotal, tier, isAnonymous
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let isAnonymous = try container.decodeIfPresent(Bool.self, forKey: .isAnonymous)
    if isAnonymous == true {
      gifter = nil
    } else {
      let gifterID = try container.decode(String.self, forKey: .userID)
      let gifterLogin = try container.decode(String.self, forKey: .userLogin)
      let gifterName = try container.decode(String.self, forKey: .userName)

      gifter = .init(userID: gifterID, userLogin: gifterLogin, userName: gifterName)
    }

    broadcasterID = try container.decode(String.self, forKey: .broadcasterID)
    broadcasterLogin = try container.decode(String.self, forKey: .broadcasterLogin)
    broadcasterName = try container.decode(String.self, forKey: .broadcasterName)

    total = try container.decode(Int.self, forKey: .total)
    cumulativeTotal = try container.decodeIfPresent(Int.self, forKey: .cumulativeTotal)

    tier = try container.decode(String.self, forKey: .tier)
  }

  public struct Gifter: Sendable {
    public let userID: String
    public let userLogin: String
    public let userName: String
  }
}
