import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func checkSubscription(to broadcasterID: String)
    -> HelixEndpoint<Subscription?, Subscription, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "GET", path: "subscriptions/user",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("user_id", credentials.userID),
        ]
      },
      makeResponse: { response in
        return response.data.first
      })
  }
}

@MemberwiseInit(.public)
public struct Subscription: Decodable, Sendable {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let gifter: SubscriptionGifter?

  public let tier: SubscriptionTier

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case broadcasterLogin
    case broadcasterDisplayName = "broadcasterName"
    case isGift
    case gifterID = "gifterId"
    case gifterLogin
    case gifterDisplayName = "gifterName"
    case tier
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.broadcasterID = try container.decode(String.self, forKey: .broadcasterID)
    self.broadcasterLogin = try container.decode(String.self, forKey: .broadcasterLogin)
    self.broadcasterDisplayName = try container.decode(
      String.self, forKey: .broadcasterDisplayName)

    if try container.decode(Bool.self, forKey: .isGift) {
      self.gifter = .init(
        id: try container.decode(String.self, forKey: .gifterID),
        login: try container.decode(String.self, forKey: .gifterLogin),
        displayName: try container.decode(String.self, forKey: .gifterDisplayName))
    } else {
      self.gifter = nil
    }

    self.tier = try container.decode(SubscriptionTier.self, forKey: .tier)
  }
}

public enum SubscriptionTier: String, Decodable, Sendable {
  case tier1 = "1000"
  case tier2 = "2000"
  case tier3 = "3000"
}

@MemberwiseInit(.public)
public struct SubscriptionGifter: Decodable, Sendable {
  public let id: String
  public let login: String
  public let displayName: String

  enum CodingKeys: String, CodingKey {
    case id, login
    case displayName = "name"
  }
}
