import Foundation

extension HelixEndpoint {
  /// Creates a clip from a broadcaster’s VOD as the broadcaster or a channel editor.
  ///
  /// Requires `editor:manage:clips` or `channel:manage:clips`. The editor ID must match
  /// the user token’s user. Twitch also documents app-token authorization.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#create-clip-from-vod
  /// ).
  ///
  /// - Parameters:
  ///   - vodID: The source VOD’s ID.
  ///   - broadcasterID: The VOD owner’s user ID.
  ///   - vodOffset: The end offset in seconds; must be at least the clip duration.
  ///   - title: The clip title.
  ///   - duration: The duration, from 5 through 60 seconds in 0.1-second increments.
  ///     `nil` uses Twitch’s default of 30 seconds.
  ///   - editorID: The acting editor’s user ID; `nil` uses the authenticated user.
  public static func createClipFromVOD(
    _ vodID: String, broadcasterID: String, vodOffset: Int, title: String,
    duration: Double? = nil, editorID: String? = nil
  ) -> HelixEndpoint<ClipCreation, ClipCreation, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "POST", path: "videos/clips",
      queryItems: { credentials in
        [
          ("editor_id", editorID ?? credentials.userID),
          ("broadcaster_id", broadcasterID), ("vod_id", vodID),
          ("vod_offset", String(vodOffset)), ("title", title),
          ("duration", duration.map(String.init(describing:))),
        ]
      }, makeResponse: { try $0.requireFirst() })
  }
}
