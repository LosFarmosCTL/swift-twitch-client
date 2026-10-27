import MemberwiseInit

extension HelixEndpoint {
  /// Gets temporary download URLs for up to ten clips from a channel.
  ///
  /// Requires `editor:manage:clips` or `channel:manage:clips`. The editor ID must match
  /// the user token’s user. Twitch also documents app-token authorization.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-clips-download
  /// ) for authorization and the endpoint-specific rate limit.
  ///
  /// - Parameters:
  ///   - clipIDs: The IDs of one through ten clips to download.
  ///   - broadcasterID: The clips’ broadcaster ID.
  ///   - editorID: The acting editor’s user ID; `nil` uses the authenticated user.
  public static func getClipsDownload(
    _ clipIDs: [String], broadcasterID: String, editorID: String? = nil
  ) -> HelixEndpoint<[ClipDownload], ClipDownload, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "clips/downloads",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("editor_id", editorID ?? credentials.userID),
        ]
          + clipIDs.map { ("clip_id", $0) }
      }, makeResponse: { $0.data })
  }
}

/// Temporary URLs for downloading the landscape and portrait versions of a clip.
@MemberwiseInit(.public)
public struct ClipDownload: Decodable, Sendable {
  /// The clip ID.
  public let clipID: String
  /// The landscape download URL, if available.
  public let landscapeDownloadURL: String?
  /// The portrait download URL, if available.
  public let portraitDownloadURL: String?

  enum CodingKeys: String, CodingKey {
    case clipID = "clipId"
    case landscapeDownloadURL = "landscapeDownloadUrl"
    case portraitDownloadURL = "portraitDownloadUrl"
  }
}
