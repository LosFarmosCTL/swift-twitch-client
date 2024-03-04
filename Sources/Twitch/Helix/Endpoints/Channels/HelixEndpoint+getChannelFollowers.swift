import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == ChannelFollowers, HelixResponseType == Follower
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

        return ChannelFollowers(
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
      },
      makeResponse: {
        return $0.data.first
      })
  }
}

public struct ChannelFollowers {
  public let total: Int

  public let followers: [Follower]

  public let cursor: PaginationCursor?
}

public struct Follower: Decodable {
  let userID: String
  let userLogin: String
  let userName: String
  let followedAt: Date

  enum CodingKeys: String, CodingKey {
    case userID = "user_id"
    case userLogin = "user_login"
    case userName = "user_name"
    case followedAt = "followed_at"
  }
}
