import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<Follow> {
  public static func getFollowedChannels(
    of user: UserID, limit: Int? = nil, after cursor: String? = nil
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("user_id", user),
      ("first", limit.map(String.init)),
      ("after", cursor))

    return .init(method: "GET", path: "channels/followed", queryItems: queryItems)
  }
}

extension HelixEndpoint where Response == ResponseTypes.Optional<Follow> {
  public static func checkFollow(from userID: String, to channelID: String) -> Self {
    let queryItems = [
      URLQueryItem(name: "user_id", value: userID),
      URLQueryItem(name: "broadcaster_id", value: channelID),
    ]

    return .init(method: "GET", path: "channels/followed", queryItems: queryItems)
  }
}

public struct Follow: Decodable {
  let broadcasterID: String
  let broadcasterLogin: String
  let broadcasterName: String
  let followedAt: Date

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcaster_id"
    case broadcasterLogin = "broadcaster_login"
    case broadcasterName = "broadcaster_name"
    case followedAt = "followed_at"
  }
}
