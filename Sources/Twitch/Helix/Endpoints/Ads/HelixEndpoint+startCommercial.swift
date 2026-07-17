import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func startCommercial(
    length: Int
  ) -> HelixEndpoint<Commercial, Commercial, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "POST", path: "channels/commercial",
      body: { auth in
        StartCommercialRequestBody(broadcasterID: auth.userID, length: length)
      },
      makeResponse: { result in
        let response = try result.requireFirst()

        return response
      })
  }
}

private struct StartCommercialRequestBody: Encodable, Sendable {
  let broadcasterID: String
  let length: Int

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case length
  }
}

@MemberwiseInit(.public)
public struct Commercial: Decodable, Sendable {
  public let length: Int
  public let message: String
  public let retryAfter: Int
}
