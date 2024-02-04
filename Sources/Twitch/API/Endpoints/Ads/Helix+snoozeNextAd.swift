import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func snoozeNextAd() async throws -> [SnoozeResult] {
    let queryItems = self.makeQueryItems(("broadcaster_id", self.authenticatedUserId))

    let (rawResponse, result): (_, HelixData<SnoozeResult>?) = try await self.request(
      .post("channels/ads/schedule/snooze"), with: queryItems)

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }

    return result.data
  }
}

public struct SnoozeResult: Decodable {
  let snoozeCount: Int
  let snoozeRefreshAt: Date
  let nextAdAt: Date

  enum CodingKeys: String, CodingKey {
    case snoozeCount = "snooze_count"
    case snoozeRefreshAt = "snooze_refresh_at"
    case nextAdAt = "next_ad_at"
  }
}
