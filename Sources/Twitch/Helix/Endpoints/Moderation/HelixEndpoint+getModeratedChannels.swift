import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getModeratedChannels(
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    (channels: [ModeratedChannel], cursor: String?), ModeratedChannel,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "moderation/channels",
      queryItems: { credentials in
        [
          ("user_id", credentials.userID),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ]
      }, makeResponse: { ($0.data, $0.pagination?.cursor) }
    )
  }
}

@MemberwiseInit(.public)
public struct ModeratedChannel: Decodable, Sendable {
  public let id: String
  public let login: String
  public let displayName: String

  enum CodingKeys: String, CodingKey {
    case id = "broadcasterId"
    case login = "broadcasterLogin"
    case displayName = "broadcasterName"
  }
}
