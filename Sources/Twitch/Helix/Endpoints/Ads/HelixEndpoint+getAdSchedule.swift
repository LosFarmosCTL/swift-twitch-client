import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == [AdSchedule], HelixResponseType == AdSchedule
{
  public static func getAdSchedule() -> Self {
    return .init(
      method: "GET", path: "channels/ads",
      queryItems: { auth in
        [("broadcaster_id", auth.userID)]
      },
      makeResponse: { $0.data })
  }
}

public struct AdSchedule: Decodable {
  public let nextAdAt: Date
  public let lastAdAt: Date
  public let duration: Int
  public let prerollFreeTime: Int
  public let snoozeCount: Int
  public let snoozeRefreshAt: Date

  enum CodingKeys: String, CodingKey {
    case nextAdAt = "next_ad_at"
    case lastAdAt = "last_ad_at"
    case duration
    case prerollFreeTime = "preroll_free_time"
    case snoozeCount = "snooze_count"
    case snoozeRefreshAt = "snooze_refresh_at"
  }
}
