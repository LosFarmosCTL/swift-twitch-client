import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getChannelFollowers(
    of broadcasterID: String? = nil,
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<FollowersResponse, Follower, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "channels/followers",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID ?? credentials.userID),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ]
      },
      makeResponse: {
        let total = try $0.require(\.total)

        return FollowersResponse(
          total: total,
          followers: $0.data,
          cursor: $0.pagination?.cursor)
      })
  }

  public static func checkFollower(_ userID: String, follows broadcasterID: String? = nil)
    -> HelixEndpoint<Follower?, Follower, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "GET", path: "channels/followers",
      queryItems: { credentials in
        [("user_id", userID), ("broadcaster_id", broadcasterID ?? credentials.userID)]
      },
      makeResponse: { $0.data.first })
  }
}

public struct FollowersResponse: Sendable {
  public let total: Int

  public let followers: [Follower]

  public let cursor: String?
}

@MemberwiseInit(.public)
public struct Follower: Decodable, Sendable {
  public let userID: String
  public let userLogin: String
  public let userDisplayName: String
  public let followedAt: Date

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case followedAt
  }
}
