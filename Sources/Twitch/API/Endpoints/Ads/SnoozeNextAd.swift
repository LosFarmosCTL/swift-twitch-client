import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func snoozeNextAd(broadcasterId: String) async throws -> [SnoozeResult] {
    let queryItems = [URLQueryItem(name: "broadcaster_id", value: broadcasterId)]
    return try await self.request(.post("channels/ads/schedule/snooze"), with: queryItems)
  }
}

public struct SnoozeResult: Decodable {
  let length: Int
  let message: String
  let retryAfter: Int

  enum CodingKeys: String, CodingKey {
    case length
    case message
    case retryAfter = "retry_after"
  }
}
