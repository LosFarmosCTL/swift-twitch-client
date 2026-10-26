import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets the authenticated broadcaster’s stream key.
  ///
  /// With a user access token, requires `channel:read:stream_key`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-stream-key
  /// ) for request limits and account requirements.
  public static func getStreamKey()
    -> HelixEndpoint<String, StreamKey, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "GET", path: "streams/key",
      queryItems: { credentials in
        [
          ("broadcaster_id", credentials.userID)
        ]
      },
      makeResponse: { response in
        let key = try response.requireFirst()

        return key.streamKey
      })
  }
}

/// The authenticated broadcaster’s secret stream key.
@MemberwiseInit(.public)
public struct StreamKey: Decodable, Sendable {
  /// The secret key used to broadcast to the channel.
  public let streamKey: String
}
