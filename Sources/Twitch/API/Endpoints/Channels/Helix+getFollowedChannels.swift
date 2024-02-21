import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<Follow> {
  public static func getFollowedChannels(
    of userId: String, limit: Int? = nil, after cursor: String? = nil
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("user_id", userId),
      ("first", limit.map(String.init)),
      ("after", cursor))

    return .init(method: "GET", path: "channels/followed", queryItems: queryItems)
  }
}

extension HelixEndpoint where Response == ResponseTypes.Object<Follow> {
  public static func checkFollow(from userId: String, to channelId: String) -> Self {
    let queryItems = [
      URLQueryItem(name: "user_id", value: userId),
      URLQueryItem(name: "broadcaster_id", value: channelId),
    ]

    return .init(method: "GET", path: "channels/followed", queryItems: queryItems)
  }
}

public struct Follow: Decodable {
  let broadcasterId: String
  let broadcasterLogin: String
  let broadcasterName: String
  let followedAt: Date

  enum CodingKeys: String, CodingKey {
    case broadcasterId = "broadcaster_id"
    case broadcasterLogin = "broadcaster_login"
    case broadcasterName = "broadcaster_name"
    case followedAt = "followed_at"
  }
}
