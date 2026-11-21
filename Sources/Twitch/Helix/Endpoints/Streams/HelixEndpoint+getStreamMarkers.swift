import Foundation

extension HelixEndpoint {
  /// Gets markers for a broadcaster’s latest stream or a specified video.
  ///
  /// With a user access token, requires `user:read:broadcast` or
  /// `channel:manage:broadcast`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/streams/#get-stream-markers
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - userID: The broadcaster whose latest stream to inspect; `nil` uses the
  ///     authenticated user. Ignored when `videoID` is supplied.
  ///   - videoID: A video to inspect instead of the broadcaster’s latest stream; `nil`
  ///     uses `userID`.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - cursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields matching items and a pagination cursor when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func getStreamMarkers(
    for userID: String? = nil,
    videoID: String? = nil,
    limit: Int? = nil,
    after cursor: String? = nil
  ) -> HelixEndpoint<StreamMarkersResponse> {
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
          ("after", cursor),
        ]
      },
      responseType: StreamMarkersByUser.self,
      makeResponse: {
        StreamMarkersResponse(users: $0.data, cursor: $0.pagination?.cursor)
      })
  }
}

/// The videos and stream markers associated with a broadcaster.
public struct StreamMarkersByUser: Decodable, Sendable {
  /// The Twitch user ID.
  public let userID: String
  /// The user’s display name.
  public let userDisplayName: String
  /// The user’s login name.
  public let userLogin: String
  /// The videos.
  public let videos: [StreamMarkersVideo]

  /// Creates a `StreamMarkersByUser` value.
  public init(
    userID: String,
    userDisplayName: String,
    userLogin: String,
    videos: [StreamMarkersVideo] = []
  ) {
    self.userID = userID
    self.userDisplayName = userDisplayName
    self.userLogin = userLogin
    self.videos = videos
  }

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userDisplayName = "userName"
    case userLogin
    case videos
  }
}

/// The markers associated with one broadcast video.
public struct StreamMarkersVideo: Decodable, Sendable {
  /// The identifier of the video.
  public let videoID: String
  /// The stream markers.
  public let markers: [StreamMarker]

  /// Creates a `StreamMarkersVideo` value.
  public init(
    videoID: String,
    markers: [StreamMarker] = []
  ) {
    self.videoID = videoID
    self.markers = markers
  }

  enum CodingKeys: String, CodingKey {
    case videoID = "videoId"
    case markers
  }

  /// A marker’s ID, creation time, video offset, label, and viewing URL.
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

    /// Creates a `StreamMarker` value.
    public init(
      id: String,
      createdAt: Date,
      positionSeconds: Int,
      description: String,
      url: String
    ) {
      self.id = id
      self.createdAt = createdAt
      self.positionSeconds = positionSeconds
      self.description = description
      self.url = url
    }

    enum CodingKeys: String, CodingKey {
      case id, createdAt, positionSeconds, description
      case url = "URL"
    }
  }
}

/// A page of stream markers.
public struct StreamMarkersResponse: Sendable {
  /// The users on this page.
  public let users: [StreamMarkersByUser]
  /// The next-page cursor, if Twitch returned one.
  public let cursor: String?

  /// Creates a `StreamMarkersResponse` value.
  public init(
    users: [StreamMarkersByUser] = [],
    cursor: String? = nil
  ) {
    self.users = users
    self.cursor = cursor
  }
}
