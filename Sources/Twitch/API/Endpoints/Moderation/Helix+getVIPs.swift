import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getVIPs(
    userIDs: [String]? = nil, limit: Int? = nil, after startCursor: String? = nil
  ) async throws -> (vips: [VIP], cursor: String?) {
    var queryItems = self.makeQueryItems(
      ("broadcaster_id", self.authenticatedUserId), ("first", limit.map(String.init)),
      ("after", startCursor))

    queryItems.append(
      contentsOf: userIDs?.compactMap { URLQueryItem(name: "user_id", value: $0) } ?? [])

    let (rawResponse, result): (_, HelixData<VIP>?) = try await self.request(
      .get("channels/vips"), with: queryItems)

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }

    return (result.data, result.pagination?.cursor)
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
