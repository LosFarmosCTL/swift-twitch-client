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
        [
          "broadcaster_id": auth.userID
        ]
      },
      makeResponse: { response in
        response.data
      })
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
