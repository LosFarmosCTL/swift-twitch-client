import Foundation

extension HelixEndpoint {
  /// Gets the authenticated broadcaster’s stream key.
  ///
  /// With a user access token, requires `channel:read:stream_key`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/streams/#get-stream-key
  /// ) for request limits and account requirements.
  public static func getStreamKey()
    -> HelixEndpoint<String>
  {
    .init(
      method: "GET", path: "streams/key",
      authentication: .user,
      queryItems: { credentials in
        [
          ("broadcaster_id", try credentials.requireUser().id)
        ]
      },
      responseType: StreamKey.self,
      makeResponse: { response in
        let key = try response.requireFirst()

        return key.streamKey
      })
  }
}

private struct StreamKey: Decodable, Sendable {
  let streamKey: String
}
