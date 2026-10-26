import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getChatters(
    in broadcasterID: String,
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<ChattersResponse, Chatter, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "chat/chatters",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("moderator_id", credentials.userID),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ]
      },
      makeResponse: {
        let total = try $0.require(\.total)

        return ChattersResponse(
          total: total,
          chatters: $0.data,
          cursor: $0.pagination?.cursor)
      })
  }
}

public struct ChattersResponse: Sendable {
  public let total: Int

  public let chatters: [Chatter]

  public let cursor: String?
}

@MemberwiseInit(.public)
public struct Chatter: Decodable, Sendable {
  public let userID: String
  public let userLogin: String
  public let userDisplayName: String

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
  }
}
