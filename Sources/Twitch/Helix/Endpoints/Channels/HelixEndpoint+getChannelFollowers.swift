import Foundation

extension HelixEndpoint {
  public static func getChannelFollowers(
    of channel: String? = nil,
    limit: Int? = nil,
    after cursor: String? = nil
  ) -> HelixEndpoint<FollowerResponse, Follower, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "channels/followers",
      queryItems: { auth in
        [
          ("broadcaster_id", channel ?? auth.userID),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ]
      },
      makeResponse: {
        guard let total = $0.total else {
          throw HelixError.missingDataInResponse(responseData: $0.rawData)
        }

        return FollowerResponse(
          total: total,
          followers: $0.data,
          cursor: $0.pagination?.cursor)
      })
  }

  public static func checkFollower(_ user: String, follows channelID: String? = nil)
    -> HelixEndpoint<Follower?, Follower, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "GET", path: "channels/followers",
      queryItems: { auth in
        [("user_id", user), ("broadcaster_id", channelID ?? auth.userID)]
      },
      makeResponse: { $0.data.first })
  }
}

public struct FollowerResponse: Sendable {
  public let total: Int

  public let followers: [Follower]

  public let cursor: String?
}

public struct Follower: Decodable, Sendable {
  public let userID: String
  public let userLogin: String
  public let userName: String
  public let followedAt: Date

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin, userName, followedAt
  }
}
