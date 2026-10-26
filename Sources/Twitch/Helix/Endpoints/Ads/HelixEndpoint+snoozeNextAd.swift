import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func snoozeNextAd()
    -> HelixEndpoint<SnoozeResult, SnoozeResult, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "POST", path: "channels/ads/schedule/snooze",
      queryItems: { credentials in [("broadcaster_id", credentials.userID)] },
      makeResponse: { result in
        let response = try result.requireFirst()

        return response
      }
    )
  }
}

@MemberwiseInit(.public)
public struct SnoozeResult: Decodable, Sendable {
  public let snoozeCount: Int
  public let snoozeRefreshAt: Date
  public let nextAdAt: Date
}
