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
  let userID: String
  let userLogin: String
  let userName: String

  let broadcasterID: String
  let broadcasterLogin: String
  let broadcasterName: String

  let gifter: SubGifter?

  let planName: String
  let tier: SubTier

  enum CodingKeys: String, CodingKey {
    case userID = "user_id"
    case userLogin = "user_login"
    case userName = "user_name"

    case broadcasterID = "broadcaster_id"
    case broadcasterLogin = "broadcaster_login"
    case broadcasterName = "broadcaster_name"

    case isGift = "is_gift"
    case gifterID = "gifter_id"
    case gifterLogin = "gifter_login"
    case gifterName = "gifter_name"

    case planName = "plan_name"
    case tier
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
