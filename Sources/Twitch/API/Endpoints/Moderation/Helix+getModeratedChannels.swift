import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getModeratedChannels(limit: Int? = nil, after cursor: String? = nil)
    async throws -> (channels: [ModeratedChannel], cursor: String?)
  {
    let queryItems = self.makeQueryItems(
      ("user_id", self.authenticatedUserId), ("first", limit.map(String.init)),
      ("after", cursor))

    let (rawResponse, result): (_, HelixData<ModeratedChannel>?) = try await self.request(
      .get("moderation/channels"), with: queryItems)

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }

    return (result.data, result.pagination?.cursor)
  }
}

public struct ModeratedChannel: Decodable {
  let id: String
  let login: String
  let displayName: String

  enum CodingKeys: String, CodingKey {
    case id = "broadcaster_id"
    case login = "broadcaster_login"
    case displayName = "broadcaster_name"
  }
}
