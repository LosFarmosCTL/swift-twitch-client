import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<Follower> {
  public static func getChannelFollowers(
    broadcasterId: String, limit: Int? = nil, after cursor: String? = nil
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterId),
      ("first", limit.map(String.init)),
      ("after", cursor))

    return .init(method: "GET", path: "channels/followers", queryItems: queryItems)
  }

  public static func checkChannelFollower(userId: String, follows channelId: String)
    -> Self
  {
    let queryItems = [
      URLQueryItem(name: "user_id", value: userId),
      URLQueryItem(name: "broadcaster_id", value: channelId),
    ]

    return .init(method: "GET", path: "channels/followers", queryItems: queryItems)
  }
}

public struct Follower: Decodable {
  let userId: String
  let userLogin: String
  let userName: String
  let followedAt: Date

  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case userLogin = "user_login"
    case userName = "user_name"
    case followedAt = "followed_at"
  }
}
