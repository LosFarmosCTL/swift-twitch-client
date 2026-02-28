import Foundation

extension HelixEndpoint {
  public static func getModerators(
    filterUserIDs: [String] = [],
    limit: Int? = nil,
    after startCursor: String? = nil
  ) -> HelixEndpoint<
    ([Moderator], String?), Moderator,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "moderation/moderators",
      queryItems: { auth in
        [
          ("broadcaster_id", auth.userID),
          ("first", limit.map(String.init)),
          ("after", startCursor),
        ] + filterUserIDs.map { ("user_id", $0) }
      }, makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

public struct Moderator: Decodable, Sendable {
  public let id: String
  public let login: String
  public let displayName: String

  enum CodingKeys: String, CodingKey {
    case id = "userId"
    case login = "userLogin"
    case displayName = "userName"
  }
}
