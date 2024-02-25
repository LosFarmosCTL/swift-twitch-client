import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<Follower> {
  public static func getChannelFollowers(
    broadcasterID: String, limit: Int? = nil, after cursor: String? = nil
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterID),
      ("first", limit.map(String.init)),
      ("after", cursor))

    return .init(method: "GET", path: "channels/followers", queryItems: queryItems)
  }
}

extension HelixEndpoint where Response == ResponseTypes.Optional<Follower> {
  public static func checkChannelFollower(userID: String, follows channelID: String)
    -> Self
  {
    let queryItems = [
      URLQueryItem(name: "user_id", value: userID),
      URLQueryItem(name: "broadcaster_id", value: channelID),
    ]

    return .init(method: "GET", path: "channels/followers", queryItems: queryItems)
  }
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
