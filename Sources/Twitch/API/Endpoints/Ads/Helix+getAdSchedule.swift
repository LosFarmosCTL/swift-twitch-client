import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getAdSchedule(broadcasterId: String) async throws -> [AdSchedule] {
    let queryItems = [URLQueryItem(name: "broadcaster_id", value: broadcasterId)]

    return try await self.request(.get("channels/ads"), with: queryItems).result
  }
}

public struct AdSchedule: Decodable {
  let nextAdAt: Date
  let lastAdAt: Date
  let duration: Int
  let prerollFreeTime: Int
  let snoozeCount: Int
  let snoozeRefreshAt: Date

  enum CodingKeys: String, CodingKey {
    case nextAdAt = "next_ad_at"
    case lastAdAt = "last_ad_at"
    case duration
    case prerollFreeTime = "preroll_free_time"
    case snoozeCount = "snooze_count"
    case snoozeRefreshAt = "snooze_refresh_at"
  }
}
