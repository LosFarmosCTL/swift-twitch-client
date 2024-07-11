import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == FollowerResponse, HelixResponseType == Follower
{
  public static func getChannelFollowers(
    of channel: UserID? = nil, limit: Int? = nil, after cursor: String? = nil
  ) -> Self {
    return .init(
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
          throw HelixError.missingDataInResponse
        }

        return FollowerResponse(
          total: total,
          followers: $0.data,
          cursor: $0.pagination?.cursor)
      })
  }
}

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == Follower?, HelixResponseType == Follower
{
  public static func checkFollower(_ user: UserID, follows channelID: String? = nil)
    -> Self
  {
    return .init(
      method: "GET", path: "channels/followers",
      queryItems: { auth in
        [("user_id", user), ("broadcaster_id", channelID ?? auth.userID)]
      }, makeResponse: { $0.data.first })
  }
}

public struct FollowerResponse {
  public let total: Int

  public let followers: [Follower]

  public let cursor: PaginationCursor?
}

public struct Follower: Decodable {
  public let userID: String
  public let userLogin: String
  public let userName: String
  public let followedAt: Date

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin, userName, followedAt
  }
}
