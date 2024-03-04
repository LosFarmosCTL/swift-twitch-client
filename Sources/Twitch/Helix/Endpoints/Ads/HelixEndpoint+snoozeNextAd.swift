import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == SnoozeResult, HelixResponseType == SnoozeResult
{
  public static func snoozeNextAd() -> Self {
    return .init(
      method: "POST", path: "channels/ads/schedule/snooze",
      queryItems: { auth in
        [("broadcaster_id", auth.userID)]
      },
      makeResponse: { result in
        guard let response = result.data.first else {
          throw HelixError.noDataInResponse
        }

        return response
      }
    )
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
