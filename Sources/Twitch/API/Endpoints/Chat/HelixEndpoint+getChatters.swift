import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<Chatter> {
  public static func getChatters(
    broadcasterId: String,
    moderatorId: String,
    limit: Int? = nil,
    after cursor: String? = nil
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterId),
      ("moderator_id", moderatorId),
      ("first", limit.map(String.init)),
      ("after", cursor))

    return .init(method: "GET", path: "chat/chatters", queryItems: queryItems)
  }
}

public struct Chatter: Decodable {
  let userId: String
  let userLogin: String
  let userName: String

  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case userLogin = "user_login"
    case userName = "user_name"
  }
}
