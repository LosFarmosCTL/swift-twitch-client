import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<SnoozeResult> {
  public static func snoozeNextAd(broadcasterId: String) -> Self {
    let queryItems = makeQueryItems(("broadcaster_id", broadcasterId))

    return .init(
      method: "POST", path: "channels/ads/schedule/snooze", queryItems: queryItems)
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
