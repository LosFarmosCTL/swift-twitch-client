import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getUserBlocklist(
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<[BlockedUser], BlockedUser, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "users/blocks",
      queryItems: { credentials in
        [
          ("broadcaster_id", credentials.userID),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ]
      },
      makeResponse: {
        $0.data
      })
  }
}

@MemberwiseInit(.public)
public struct BlockedUser: Decodable, Sendable {
  public let userID: String
  public let userLogin: String
  public let displayName: String

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case displayName
  }
}
