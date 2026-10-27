import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets markers for a broadcaster’s latest stream or a specified video.
  ///
  /// With a user access token, requires `user:read:broadcast` or
  /// `channel:manage:broadcast`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-stream-markers
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - userID: The broadcaster whose latest stream to inspect; `nil` uses the
  ///     authenticated user. Ignored when `videoID` is supplied.
  ///   - videoID: A video to inspect instead of the broadcaster’s latest stream; `nil`
  ///     uses `userID`.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - beforeCursor: The pagination cursor for the previous page; `nil` omits it.
  ///   - afterCursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields matching items and a pagination cursor when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func getStreamMarkers(
    for userID: String? = nil,
    videoID: String? = nil,
    limit: Int? = nil,
    before beforeCursor: String? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    (users: [StreamMarkersByUser], cursor: String?), StreamMarkersByUser,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "streams/markers",
      authentication: .user,
      queryItems: { credentials in
        let resolvedUserID =
          videoID == nil
          ? (try credentials.resolveUserID(userID, parameter: "user_id")) : nil

        return [
          ("user_id", resolvedUserID),
          ("video_id", videoID),
          ("first", limit.map(String.init)),
          ("before", beforeCursor),
          ("after", afterCursor),
        ]
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

/// The videos and stream markers associated with a broadcaster.
@MemberwiseInit(.public)
public struct StreamMarkersByUser: Decodable, Sendable {
  /// The Twitch user ID.
  public let userID: String
  /// The user’s display name.
  public let userDisplayName: String
  /// The user’s login name.
  public let userLogin: String
  /// The videos.
  public let videos: [StreamMarkersVideo]

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userDisplayName = "userName"
    case userLogin
    case videos
  }
}

/// The markers associated with one broadcast video.
@MemberwiseInit(.public)
public struct StreamMarkersVideo: Decodable, Sendable {
  /// The identifier of the video.
  public let videoID: String
  /// The stream markers.
  public let markers: [StreamMarker]

  enum CodingKeys: String, CodingKey {
    case videoID = "videoId"
    case markers
  }

  /// A marker’s ID, creation time, video offset, label, and viewing URL.
  @MemberwiseInit(.public)
  public struct StreamMarker: Decodable, Sendable {
    /// The identifier assigned by Twitch.
    public let id: String
    /// The time the resource was created.
    public let createdAt: Date
    /// The position within the video, in seconds.
    public let positionSeconds: Int
    /// The descriptive text supplied by Twitch.
    public let description: String
    /// The URL associated with this resource.
    public let url: String
  }
}
