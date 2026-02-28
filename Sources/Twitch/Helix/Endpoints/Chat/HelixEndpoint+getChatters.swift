import Foundation

extension HelixEndpoint {
  public static func getChatters(
    in channel: String,
    limit: Int? = nil,
    after cursor: String? = nil
  ) -> HelixEndpoint<Chatters, Chatter, HelixEndpointResponseTypes.Normal> {
    .init(
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
          throw HelixError.missingDataInResponse(responseData: $0.rawData)
        }

        return Chatters(
          total: total,
          chatters: $0.data,
          cursor: $0.pagination?.cursor)
      })
  }
}

public struct Chatters: Sendable {
  public let total: Int

  public let chatters: [Chatter]

  public let cursor: String?
}

public struct Chatter: Decodable, Sendable {
  public let userID: String
  public let userLogin: String
  public let userName: String

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin, userName
  }
}
