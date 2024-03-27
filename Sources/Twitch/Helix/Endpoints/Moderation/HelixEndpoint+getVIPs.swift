import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == ([VIP], PaginationCursor?), HelixResponseType == VIP
{
  public static func getVIPs(
    filterUserIDs: [String] = [],
    limit: Int? = nil,
    after startCursor: String? = nil
  ) -> Self {
    return .init(
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

public struct VIP: Decodable {
  public let id: String
  public let login: String
  public let displayName: String

  enum CodingKeys: String, CodingKey {
    case id = "user_id"
    case login = "user_login"
    case displayName = "user_name"
  }
}
