import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<Chatter> {
  public static func getChatters(
    in channel: UserID,
    moderatorID: String,
    limit: Int? = nil,
    after cursor: String? = nil
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", channel),
      ("moderator_id", moderatorID),
      ("first", limit.map(String.init)),
      ("after", cursor))

    return .init(method: "GET", path: "chat/chatters", queryItems: queryItems)
  }
}

public struct Chatter: Decodable {
  let userID: String
  let userLogin: String
  let userName: String

  enum CodingKeys: String, CodingKey {
    case userID = "user_id"
    case userLogin = "user_login"
    case userName = "user_name"
  }
}
