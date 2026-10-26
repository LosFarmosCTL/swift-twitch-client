import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getBannedUsers(
    userIDs: [String] = [],
    limit: Int? = nil,
    after afterCursor: String? = nil,
    before beforeCursor: String? = nil
  ) -> HelixEndpoint<
    (users: [BannedUser], cursor: String?), BannedUser,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "moderation/banned",
      queryItems: { credentials in
        [
          ("broadcaster_id", credentials.userID),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
          ("before", beforeCursor),
        ] + userIDs.map { ("user_id", $0) }
      },
      makeResponse: {
        ($0.data, $0.pagination?.cursor)
      })
  }
}

@MemberwiseInit(.public)
public struct BannedUser: Decodable, Sendable {
  public let userID: String
  public let userLogin: String
  public let userDisplayName: String

  public let expiresAt: Date
  public let createdAt: Date

  public let reason: String?

  public let moderatorID: String
  public let moderatorLogin: String
  public let moderatorDisplayName: String

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case expiresAt
    case createdAt
    case reason
    case moderatorID = "moderatorId"
    case moderatorLogin
    case moderatorDisplayName = "moderatorName"
  }
}
