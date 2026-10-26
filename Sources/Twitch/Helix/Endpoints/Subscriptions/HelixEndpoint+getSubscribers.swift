import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getSubscribers(
    userIDs: [String] = [],
    limit: Int? = nil,
    after afterCursor: String? = nil,
    before beforeCursor: String? = nil
  ) -> HelixEndpoint<SubscribersResponse, Subscriber, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "subscriptions",
      queryItems: { credentials in
        [
          ("broadcaster_id", credentials.userID),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
          ("before", beforeCursor),
        ] + userIDs.map { ("user_id", $0) }
      },
      makeResponse: {
        let total = try $0.require(\.total)
        let points = try $0.require(\.points)

        return SubscribersResponse(
          subscribers: $0.data,
          total: total,
          points: points,
          cursor: $0.pagination?.cursor)
      })
  }
}

public struct SubscribersResponse: Sendable {
  public let subscribers: [Subscriber]

  public let total: Int
  public let points: Int

  public let cursor: String?
}

@MemberwiseInit(.public)
public struct Subscriber: Decodable, Sendable {
  public let userID: String
  public let userLogin: String
  public let userDisplayName: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let gifter: SubscriptionGifter?

  public let planName: String
  public let tier: SubscriptionTier

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case broadcasterID = "broadcasterId"
    case broadcasterLogin
    case broadcasterDisplayName = "broadcasterName"
    case isGift
    case gifterID = "gifterId"
    case gifterLogin
    case gifterDisplayName = "gifterName"
    case planName
    case tier
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.userID = try container.decode(String.self, forKey: .userID)
    self.userLogin = try container.decode(String.self, forKey: .userLogin)
    self.userDisplayName = try container.decode(String.self, forKey: .userDisplayName)

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

    self.planName = try container.decode(String.self, forKey: .planName)
    self.tier = try container.decode(SubscriptionTier.self, forKey: .tier)
  }
}
