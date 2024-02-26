import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<SnoozeResult> {
  public static func snoozeNextAd(on channel: UserID) -> Self {
    let queryItems = makeQueryItems(("broadcaster_id", channel))

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
