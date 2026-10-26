import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getFollowedChannels(
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    FollowedChannelsResponse, Follow, HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "channels/followed",
      queryItems: { credentials in
        [
          ("user_id", credentials.userID),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ]
      },
      makeResponse: {
        let total = try $0.require(\.total)

        return FollowedChannelsResponse(
          total: total,
          follows: $0.data,
          cursor: $0.pagination?.cursor)
      })
  }

  public static func checkFollow(to broadcasterID: String)
    -> HelixEndpoint<Follow?, Follow, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "GET", path: "channels/followed",
      queryItems: { credentials in
        [("user_id", credentials.userID), ("broadcaster_id", broadcasterID)]
      },
      makeResponse: { $0.data.first })
  }
}

public struct FollowedChannelsResponse: Sendable {
  public let total: Int

  public let follows: [Follow]

  public let cursor: String?
}

@MemberwiseInit(.public)
public struct Follow: Decodable, Sendable {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String
  public let followedAt: Date

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case broadcasterLogin
    case broadcasterDisplayName = "broadcasterName"
    case followedAt
  }
}
