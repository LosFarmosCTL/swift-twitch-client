import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<ModeratedChannel> {
  public static func getModeratedChannels(
    of userId: String, limit: Int? = nil, after cursor: String? = nil
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("user_id", userId),
      ("first", limit.map(String.init)),
      ("after", cursor))

    return .init(method: "GET", path: "moderation/channels", queryItems: queryItems)
  }
}

public struct ModeratedChannel: Decodable {
  let id: String
  let login: String
  let displayName: String

  enum CodingKeys: String, CodingKey {
    case id = "broadcaster_id"
    case login = "broadcaster_login"
    case displayName = "broadcaster_name"
  }
}
