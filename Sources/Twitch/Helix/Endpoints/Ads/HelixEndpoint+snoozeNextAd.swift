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
          throw HelixError.noDataInResponse(responseData: result.rawData)
        }

        return response
      }
    )
  }
}

public struct SnoozeResult: Decodable, Sendable {
  public let snoozeCount: Int
  public let snoozeRefreshAt: Date
  public let nextAdAt: Date
}
