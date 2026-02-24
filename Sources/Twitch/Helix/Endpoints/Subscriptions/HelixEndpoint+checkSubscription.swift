import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == Subscription?,
  HelixResponseType == Subscription
{
  public static func checkSubscription(to channel: String) -> Self {
    return .init(
      method: "GET", path: "subscriptions/user",
      queryItems: { auth in
        [
          ("broadcaster_id", channel),
          ("user_id", auth.userID),
        ]
      },
      makeResponse: { response in
        return response.data.first
      })
  }
}

public struct Subscription: Decodable, Sendable {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let gifter: SubGifter?

  public let tier: SubTier

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case broadcasterLogin, broadcasterName

    case isGift
    case gifterID = "gifterId"
    case gifterLogin, gifterName

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

public enum SubTier: String, Decodable, Sendable {
  case tier1 = "1000"
  case tier2 = "2000"
  case tier3 = "3000"
}

public struct SubGifter: Decodable, Sendable {
  public let id: String
  public let login: String
  public let name: String
}
