import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<BlockedUser> {
  public static func getBlocklist(
    of user: UserID, limit: Int? = nil, after cursor: String? = nil
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", user),
      ("first", limit.map(String.init)),
      ("after", cursor))

    return .init(method: "GET", path: "users/blocks", queryItems: queryItems)
  }
}

public struct BlockedUser: Decodable {
  let userID: String
  let userLogin: String
  let displayName: String

  enum CodingKeys: String, CodingKey {
    case userID = "user_id"
    case userLogin = "user_login"
    case displayName = "display_name"
  }
}
