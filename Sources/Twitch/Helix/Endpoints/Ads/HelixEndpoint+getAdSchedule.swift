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
}
