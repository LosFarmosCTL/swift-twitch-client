import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<VIP> {
  public static func getVIPs(
    for broadcasterId: String,
    filterUserIDs: [String] = [],
    limit: Int? = nil,
    after startCursor: String? = nil
  ) -> Self {
    var queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterId),
      ("first", limit.map(String.init)),
      ("after", startCursor))

    queryItems.append(
      contentsOf: filterUserIDs.compactMap { URLQueryItem(name: "user_id", value: $0) })

    return .init(method: "GET", path: "channels/vips", queryItems: queryItems)
  }
}

public struct VIP: Decodable {
  let id: String
  let login: String
  let displayName: String

  enum CodingKeys: String, CodingKey {
    case id = "user_id"
    case login = "user_login"
    case displayName = "user_name"
  }
}
