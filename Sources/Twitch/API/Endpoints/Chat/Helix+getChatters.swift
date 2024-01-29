import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getChatters(
    broadcasterId: String, limit: Int? = nil, after cursor: String? = nil
  ) async throws -> (total: Int, chatters: [Chatter], cursor: String?) {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterId), ("moderator_id", self.authenticatedUserId),
      ("limit", limit.map(String.init)), ("after", cursor))

    let (rawResponse, result): (_, HelixData<Chatter>?) = try await self.request(
      .get("chat/chatters"), with: queryItems)

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }
    guard let total = result.total else {
      throw HelixError.invalidResponse(rawResponse: rawResponse)
    }

    return (total, result.data, result.pagination?.cursor)
  }
}

public struct Chatter: Decodable {
  let userId: String
  let userLogin: String
  let userName: String

  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case userLogin = "user_login"
    case userName = "user_name"
  }
}
