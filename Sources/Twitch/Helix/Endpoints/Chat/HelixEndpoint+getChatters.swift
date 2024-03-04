import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == Chatters, HelixResponseType == Chatter
{
  public static func getChatters(
    in channel: UserID,
    limit: Int? = nil,
    after cursor: String? = nil
  ) -> Self {
    return .init(
      method: "GET", path: "chat/chatters",
      queryItems: { auth in
        [
          ("broadcaster_id", channel),
          ("moderator_id", auth.userID),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ]
      },
      makeResponse: {
        guard let total = $0.total else {
          throw HelixError.missingDataInResponse
        }

        return Chatters(
          total: total,
          chatters: $0.data,
          cursor: $0.pagination?.cursor)
      })
  }
}

public struct Chatters {
  public let total: Int

  public let chatters: [Chatter]

  public let cursor: PaginationCursor?
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
