import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getFollowedChannels(
    userId: String, limit: Int? = nil, after cursor: String? = nil
  ) async throws -> (total: Int, follows: [Follow], cursor: String?) {
    let queryItems = self.makeQueryItems(
      ("user_id", userId), ("first", limit.map(String.init)), ("after", cursor))

    let (rawResponse, result): (_, HelixData<Follow>?) = try await self.request(
      .get("channels/followed"), with: queryItems)

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }
    guard let total = result.total else {
      throw HelixError.invalidResponse(rawResponse: rawResponse)
    }

    return (total, result.data, result.pagination?.cursor)
  }

  public func checkFollow(from userId: String, to channelId: String) async throws
    -> Follow?
  {
    let queryItems = [
      URLQueryItem(name: "user_id", value: userId),
      URLQueryItem(name: "broadcaster_id", value: channelId),
    ]

    let (rawResponse, result): (_, HelixData<Follow>?) = try await self.request(
      .get("channels/followed"), with: queryItems)

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }

    return result.data.first
  }
}

public struct Follow: Decodable {
  let broadcasterId: String
  let broadcasterLogin: String
  let broadcasterName: String
  let followedAt: Date

  enum CodingKeys: String, CodingKey {
    case broadcasterId = "broadcaster_id"
    case broadcasterLogin = "broadcaster_login"
    case broadcasterName = "broadcaster_name"
    case followedAt = "followed_at"
  }
}
