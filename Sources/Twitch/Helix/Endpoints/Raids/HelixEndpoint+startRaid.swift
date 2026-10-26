import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func startRaid(
    to toBroadcasterID: String
  ) -> HelixEndpoint<PendingRaid, PendingRaid, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "POST", path: "raids",
      queryItems: { credentials in
        [
          ("from_broadcaster_id", credentials.userID),
          ("to_broadcaster_id", toBroadcasterID),
        ]
      },
      makeResponse: {
        let response = try $0.requireFirst()

        return response
      })
  }
}

@MemberwiseInit(.public)
public struct PendingRaid: Decodable, Sendable {
  public let createdAt: Date
  public let isMature: Bool

  enum CodingKeys: String, CodingKey {
    case createdAt
    case isMature
  }
}
