import Foundation

extension HelixEndpoint {
  public static func getFollowedChannels(
    limit: Int? = nil,
    after cursor: String? = nil
  ) -> HelixEndpoint<FollowsResponse, Follow, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "channels/followed",
      queryItems: { auth in
        [
          ("user_id", auth.userID),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ]
      },
      makeResponse: {
        guard let total = $0.total else {
          throw HelixError.missingDataInResponse(responseData: $0.rawData)
        }

        return FollowsResponse(
          total: total,
          follows: $0.data,
          cursor: $0.pagination?.cursor)
      })
  }

  public static func checkFollow(to channelID: String)
    -> HelixEndpoint<Follow?, Follow, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "GET", path: "channels/followed",
      queryItems: { auth in
        [("user_id", auth.userID), ("broadcaster_id", channelID)]
      },
      makeResponse: { $0.data.first })
  }
}

public struct FollowsResponse: Sendable {
  public let total: Int

  public let follows: [Follow]

  public let cursor: String?
}

public struct Follow: Decodable, Sendable {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String
  public let followedAt: Date

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case broadcasterLogin, broadcasterName, followedAt
  }
}
