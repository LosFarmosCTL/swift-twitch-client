import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getChannelFollowers(
    broadcasterId: String, limit: Int? = nil, after cursor: String? = nil
  ) async throws -> (total: Int, follows: [Follower], cursor: String?) {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterId), ("first", limit.map(String.init)),
      ("after", cursor))

    let (rawResponse, result): (_, HelixData<Follower>?) = try await self.request(
      .get("channels/followers"), with: queryItems)

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }
    guard let total = result.total else {
      throw HelixError.invalidResponse(rawResponse: rawResponse)
    }

    return (total, result.data, result.pagination?.cursor)
  }

  public func checkChannelFollower(userId: String, follows channelId: String) async throws
    -> Follower?
  {
    let queryItems = [
      URLQueryItem(name: "user_id", value: userId),
      URLQueryItem(name: "broadcaster_id", value: channelId),
    ]

    let (rawResponse, result): (_, HelixData<Follower>?) = try await self.request(
      .get("channels/followers"), with: queryItems)

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }

    return result.data.first
  }
}

public struct Follower: Decodable {
  let userId: String
  let userLogin: String
  let userName: String
  let followedAt: Date

  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case userLogin = "user_login"
    case userName = "user_name"
    case followedAt = "followed_at"
  }
}
