import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<BlockedUser> {
  public static func getUserBlocklist(
    broadcasterId: String, limit: Int? = nil, after cursor: String? = nil
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterId),
      ("first", limit.map(String.init)),
      ("after", cursor))

    return .init(method: "GET", path: "users/blocks", queryItems: queryItems)
  }
}

public struct BlockedUser: Decodable {
  let userId: String
  let userLogin: String
  let displayName: String

  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case userLogin = "user_login"
    case displayName = "display_name"
  }
}
