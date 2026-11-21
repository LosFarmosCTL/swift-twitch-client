import Foundation

extension HelixEndpoint {
  /// Gets videos by ID, broadcaster, or game category.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/videos/#get-videos
  /// ) for request limits and account requirements.
  ///
  /// Specify exactly one selector: a nonempty `videoIDs` array, `userID`, or `gameID`.
  /// Twitch rejects requests with no selector or with more than one selector. This
  /// factory passes the filters through without validating them.
  ///
  /// - Parameters:
  ///   - videoIDs: The video IDs to include in the request. Defaults to `[]`.
  ///   - userID: The Twitch user ID, when provided.
  ///   - gameID: The identifier of the game, when provided.
  ///   - language: The language code to apply or filter by.
  ///   - period: The reporting period.
  ///   - sort: The order of the returned results.
  ///   - type: The video kinds to include; `nil` uses Twitch’s default of all video
  ///     types.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - afterCursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///   - beforeCursor: The pagination cursor for the previous page; `nil` omits it.
  ///
  /// - Returns: An endpoint that yields ``VideosResponse`` when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func getVideos(
    videoIDs: [String] = [],
    userID: String? = nil,
    gameID: String? = nil,
    language: String? = nil,
    period: VideoPeriod? = nil,
    sort: VideoSort? = nil,
    type: VideoTypeFilter? = nil,
    limit: Int? = nil,
    after afterCursor: String? = nil,
    before beforeCursor: String? = nil
  ) -> HelixEndpoint<VideosResponse> {
    let idQueryItems = videoIDs.map { ("id", $0) }

    return .init(
      method: "GET", path: "videos",
      authentication: .either,
      queryItems: { _ in
        [
          ("user_id", userID),
          ("game_id", gameID),
          ("language", language),
          ("period", period?.rawValue),
          ("sort", sort?.rawValue),
          ("type", type?.rawValue),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
          ("before", beforeCursor),
        ] + idQueryItems
      },
      responseType: Video.self,
      makeResponse: { VideosResponse(videos: $0.data, cursor: $0.pagination?.cursor) })
  }
}

/// The lookback period used to filter videos by age.
public enum VideoPeriod: String, Sendable {
  /// Includes all supported entries or periods.
  case all
  /// Limits results to the past day.
  case day
  /// Limits results to the past week.
  case week
  /// Limits results to the past month.
  case month
}

/// The ordering used when retrieving videos.
public enum VideoSort: String, Sendable {
  /// Orders videos by creation time.
  case time
  /// Orders videos by trending popularity.
  case trending
  /// Orders videos by view count.
  case views
}

/// The kinds of video to include in a query.
public enum VideoTypeFilter: String, Sendable {
  /// Includes all supported entries or periods.
  case all
  /// A past broadcast.
  case archive
  /// A highlighted section of a broadcast.
  case highlight
  /// An uploaded video.
  case upload
}

/// A Twitch video’s identity, playback metadata, and muted segments.
public struct Video: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The identifier of the stream, when provided.
  public let streamID: String?
  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The user’s display name.
  public let userDisplayName: String
  /// The title shown to viewers.
  public let title: String
  /// The descriptive text supplied by Twitch.
  public let description: String
  /// The time the resource was created.
  public let createdAt: Date
  /// The time the content was published.
  public let publishedAt: Date?
  /// The URL associated with this resource.
  public let url: String
  /// The URL template for the video's thumbnail image.
  public let thumbnailURL: String
  /// The visibility of the video.
  public let viewable: String
  /// The number of times the content has been viewed.
  public let viewCount: Int
  /// The language code reported by Twitch.
  public let language: String
  /// Whether the video is an archive, highlight, or upload.
  public let type: VideoType
  /// The video duration as Twitch’s formatted duration string.
  public let duration: String
  /// The muted portions of the video, when provided.
  public let mutedSegments: [MutedSegment]?

  /// Creates a `Video` value.
  public init(
    id: String,
    streamID: String? = nil,
    userID: String,
    userLogin: String,
    userDisplayName: String,
    title: String,
    description: String,
    createdAt: Date,
    publishedAt: Date? = nil,
    url: String,
    thumbnailURL: String,
    viewable: String,
    viewCount: Int,
    language: String,
    type: VideoType,
    duration: String,
    mutedSegments: [MutedSegment]? = nil
  ) {
    self.id = id
    self.streamID = streamID
    self.userID = userID
    self.userLogin = userLogin
    self.userDisplayName = userDisplayName
    self.title = title
    self.description = description
    self.createdAt = createdAt
    self.publishedAt = publishedAt
    self.url = url
    self.thumbnailURL = thumbnailURL
    self.viewable = viewable
    self.viewCount = viewCount
    self.language = language
    self.type = type
    self.duration = duration
    self.mutedSegments = mutedSegments
  }

  enum CodingKeys: String, CodingKey {
    case id
    case streamID = "streamId"
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case title
    case description
    case createdAt
    case publishedAt
    case url
    case thumbnailURL = "thumbnailUrl"
    case viewable
    case viewCount
    case language
    case type
    case duration
    case mutedSegments
  }
}

/// Whether a video is a past broadcast, highlight, or upload, preserving unfamiliar values
/// in `rawValue`.
public struct VideoType: RawRepresentable, Decodable, Sendable, Hashable {
  /// The exact video type string supplied by Twitch or the caller.
  public let rawValue: String

  /// Creates a video type from any raw string.
  public init(rawValue: String) { self.rawValue = rawValue }

  /// Decodes a video type from a single string.
  public init(from decoder: Decoder) throws {
    self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
  }

  /// A past Premiere, returned when querying by video ID.
  public static let pastPremiere = Self(rawValue: "past_premiere")
  /// A Premiere upload, returned when querying by video ID.
  public static let premiereUpload = Self(rawValue: "premiere_upload")
  /// A past broadcast.
  public static let archive = Self(rawValue: "archive")
  /// A highlighted section of a broadcast.
  public static let highlight = Self(rawValue: "highlight")
  /// An uploaded video.
  public static let upload = Self(rawValue: "upload")
}

/// A muted interval within a Twitch video.
public struct MutedSegment: Decodable, Sendable {
  /// The muted segment’s duration, in seconds.
  public let duration: Int
  /// The offset from the beginning of the content.
  public let offset: Int

  /// Creates a `MutedSegment` value.
  public init(
    duration: Int,
    offset: Int
  ) {
    self.duration = duration
    self.offset = offset
  }
}

/// A page of videos.
public struct VideosResponse: Sendable {
  /// The videos on this page.
  public let videos: [Video]
  /// The next-page cursor, if Twitch returned one.
  public let cursor: String?

  /// Creates a `VideosResponse` value.
  public init(
    videos: [Video] = [],
    cursor: String? = nil
  ) {
    self.videos = videos
    self.cursor = cursor
  }
}
