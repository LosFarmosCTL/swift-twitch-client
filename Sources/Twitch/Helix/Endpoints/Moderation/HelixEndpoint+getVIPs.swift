import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getVIPs(
    userIDs: [String] = [],
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    (vips: [VIP], cursor: String?),
    VIP, HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "channels/vips",
      queryItems: { credentials in
        [
          ("broadcaster_id", credentials.userID),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ] + userIDs.map { ("user_id", $0) }
      }, makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

@MemberwiseInit(.public)
public struct VIP: Decodable, Sendable {
  public let id: String
  public let login: String
  public let displayName: String

  enum CodingKeys: String, CodingKey {
    case id = "userId"
    case login = "userLogin"
    case displayName = "userName"
  }
}
