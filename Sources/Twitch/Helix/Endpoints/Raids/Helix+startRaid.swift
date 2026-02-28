import Foundation

extension HelixEndpoint {
  public static func startRaid(
    to channel: String
  ) -> HelixEndpoint<PendingRaid, PendingRaid, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "POST", path: "raids",
      queryItems: { auth in
        [
          ("from_broadcaster_id", auth.userID),
          ("to_broadcaster_id", channel),
        ]
      },
      makeResponse: {
        guard let response = $0.data.first else {
          throw HelixError.noDataInResponse(responseData: $0.rawData)
        }

        return response
      })
  }
}

public struct PendingRaid: Decodable, Sendable {
  public let createdAt: Date
  public let isMature: Bool

  enum CodingKeys: String, CodingKey {
    case createdAt
    case isMature
  }
}
