import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getStreamKey()
    -> HelixEndpoint<String, StreamKey, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "GET", path: "streams/key",
      queryItems: { auth in
        [
          ("broadcaster_id", auth.userID)
        ]
      },
      makeResponse: { response in
        let key = try response.requireFirst()

        return key.streamKey
      })
  }
}

@MemberwiseInit(.public)
public struct StreamKey: Decodable, Sendable {
  public let streamKey: String
}
