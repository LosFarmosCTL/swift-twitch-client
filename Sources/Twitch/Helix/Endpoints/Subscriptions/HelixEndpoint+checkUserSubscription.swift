import Foundation

extension HelixEndpoint where Response == ResponseTypes.Optional<Subscription> {
  public static func checkUserSubscription(
    of userID: String, to channelID: String
  ) -> Self {
    let queryItems = [
      URLQueryItem(name: "broadcaster_id", value: channelID),
      URLQueryItem(name: "user_id", value: userID),
    ]

    return .init(method: "GET", path: "subscriptions/user", queryItems: queryItems)
  }
}

public struct Subscription: Decodable {
  let broadcasterID: String
  let broadcasterLogin: String
  let broadcasterName: String

  let gifter: SubGifter?

  let tier: SubTier

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcaster_id"
    case broadcasterLogin = "broadcaster_login"
    case broadcasterName = "broadcaster_name"

    case isGift = "is_gift"
    case gifterID = "gifter_id"
    case gifterLogin = "gifter_login"
    case gifterName = "gifter_name"

    case tier
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.broadcasterID = try container.decode(String.self, forKey: .broadcasterID)
    self.broadcasterLogin = try container.decode(String.self, forKey: .broadcasterLogin)
    self.broadcasterName = try container.decode(String.self, forKey: .broadcasterName)

    if try container.decode(Bool.self, forKey: .isGift) {
      self.gifter = .init(
        id: try container.decode(String.self, forKey: .gifterID),
        login: try container.decode(String.self, forKey: .gifterLogin),
        name: try container.decode(String.self, forKey: .gifterName))
    } else {
      self.gifter = nil
    }

    self.tier = try container.decode(SubTier.self, forKey: .tier)
  }
}

public enum SubTier: String, Decodable {
  case tier1 = "1000"
  case tier2 = "2000"
  case tier3 = "3000"
}

public struct SubGifter: Decodable {
  let id: String
  let login: String
  let name: String
}
