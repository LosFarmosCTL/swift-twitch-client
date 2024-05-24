import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == SubscribersResponse, HelixResponseType == Subscriber
{
  public static func getSubscribers(
    filterUserIDs: [String] = [],
    limit: Int? = nil,
    after startCursor: String? = nil,
    before endCursor: String? = nil
  ) -> Self {
    return .init(
      method: "GET", path: "subscriptions",
      queryItems: { auth in
        [
          ("broadcaster_id", auth.userID),
          ("first", limit.map(String.init)),
          ("after", startCursor),
          ("before", endCursor),
        ] + filterUserIDs.map { ("user_id", $0) }
      },
      makeResponse: {
        guard let total = $0.total, let points = $0.points else {
          throw HelixError.missingDataInResponse
        }

        return SubscribersResponse(
          subscribers: $0.data,
          total: total,
          points: points,
          cursor: $0.pagination?.cursor)
      })
  }
}

public struct SubscribersResponse {
  public let subscribers: [Subscriber]

  public let total: Int
  public let points: Int

  public let cursor: PaginationCursor?
}

public struct Subscriber: Decodable {
  public let userID: String
  public let userLogin: String
  public let userName: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let gifter: SubGifter?

  public let planName: String
  public let tier: SubTier

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin, userName

    case broadcasterID = "broadcasterId"
    case broadcasterLogin, broadcasterName

    case isGift
    case gifterID = "gifterId"
    case gifterLogin, gifterName

    case planName, tier
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.userID = try container.decode(String.self, forKey: .userID)
    self.userLogin = try container.decode(String.self, forKey: .userLogin)
    self.userName = try container.decode(String.self, forKey: .userName)

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

    self.planName = try container.decode(String.self, forKey: .planName)
    self.tier = try container.decode(SubTier.self, forKey: .tier)
  }
}
