import Foundation

extension HelixEndpoint {
  public static func getAdSchedule()
    -> HelixEndpoint<[AdSchedule], AdSchedule, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "GET", path: "channels/ads",
      queryItems: { auth in [("broadcaster_id", auth.userID)] },
      makeResponse: { $0.data }
    )
  }
}

public struct AdSchedule: Decodable, Sendable {
  public let nextAdAt: Date
  public let lastAdAt: Date
  public let duration: Int
  public let prerollFreeTime: Int
  public let snoozeCount: Int
  public let snoozeRefreshAt: Date
}
