import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getChannelEditors(broadcasterId: String) async throws -> [Editor] {
    let queryItems = [URLQueryItem(name: "broadcaster_id", value: broadcasterId)]

    let (rawResponse, result): (String, HelixData<Editor>?) = try await self.request(
      .get("channels/editors"), with: queryItems)

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }

    return result.data
  }
}

public struct Editor: Decodable {
  let userId: String
  let userName: String
  let createdAt: Date

  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case userName = "user_name"
    case createdAt = "created_at"
  }
}
