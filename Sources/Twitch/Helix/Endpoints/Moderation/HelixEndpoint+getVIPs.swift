import Foundation

extension HelixEndpoint {
  public static func getVIPs(
    filterUserIDs: [String] = [],
    limit: Int? = nil,
    after startCursor: String? = nil
  ) -> HelixEndpoint<([VIP], String?), VIP, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "channels/vips",
      queryItems: { auth in
        [
          ("broadcaster_id", auth.userID),
          ("first", limit.map(String.init)),
          ("after", startCursor),
        ] + filterUserIDs.map { ("user_id", $0) }
      }, makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

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
