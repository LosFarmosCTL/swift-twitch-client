import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<AdSchedule> {
  public static func getAdSchedule(of channel: UserID) -> Self {
    let queryItems = makeQueryItems(("broadcaster_id", channel))

    return .init(method: "GET", path: "channels/ads", queryItems: queryItems)
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
