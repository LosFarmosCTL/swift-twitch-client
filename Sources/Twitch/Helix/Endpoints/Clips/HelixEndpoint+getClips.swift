import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets clips by ID, broadcaster, or game category.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-clips
  /// ) for request limits and account requirements.
  ///
  /// Specify exactly one selector: a nonempty `clipIDs` array, `broadcasterID`, or
  /// `gameID`. Twitch rejects requests with no selector or with more than one selector.
  /// This factory passes the filters through without validating them.
  ///
  /// - Parameters:
  ///   - clipIDs: The clip IDs to include in the request. Defaults to `[]`.
  ///   - broadcasterID: The Twitch user ID of the broadcaster, when provided.
  ///   - gameID: The identifier of the game, when provided.
  ///   - startedAt: The beginning of the requested time range.
  ///   - endedAt: The end of the requested time range.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - beforeCursor: The pagination cursor for the previous page; `nil` omits it.
  ///   - afterCursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///   - isFeatured: Whether the resource is featured, when provided.
  ///
  /// - Returns: An endpoint that yields matching items and a pagination cursor when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func getClips(
    clipIDs: [String] = [],
    broadcasterID: String? = nil,
    gameID: String? = nil,
    startedAt: Date? = nil,
    endedAt: Date? = nil,
    limit: Int? = nil,
    before beforeCursor: String? = nil,
    after afterCursor: String? = nil,
    isFeatured: Bool? = nil
  ) -> HelixEndpoint<
    (clips: [Clip], cursor: String?),
    Clip, HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "clips",
      authentication: .either,
      queryItems: { _ in
        [
          ("broadcaster_id", broadcasterID),
          ("game_id", gameID),
          ("started_at", startedAt?.formatted(.iso8601)),
          ("ended_at", endedAt?.formatted(.iso8601)),
          ("first", limit.map(String.init)),
          ("before", beforeCursor),
          ("after", afterCursor),
          ("is_featured", isFeatured.map(String.init)),
        ] + clipIDs.map { ("id", $0) }
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

/// A Twitch clip’s broadcaster, creator, playback, and source-video metadata.
@MemberwiseInit(.public)
public struct Clip: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The URL associated with this resource.
  public let url: String
  /// The URL for embed.
  public let embedURL: String

  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The Twitch user ID of the creator.
  public let creatorID: String
  /// The display name of the creator.
  public let creatorDisplayName: String

  /// The identifier of the video.
  public let videoID: String
  /// The identifier of the game.
  public let gameID: String

  /// The language code reported by Twitch.
  public let language: String
  /// The title shown to viewers.
  public let title: String
  /// The number of times the content has been viewed.
  public let viewCount: Int
  /// The time the resource was created.
  public let createdAt: Date
  /// The URL for thumbnail.
  public let thumbnailURL: String
  /// The clip’s duration, in seconds.
  public let duration: Double
  /// The offset within the VOD, in seconds, when available.
  public let vodOffset: Int?
  /// Whether the resource is featured.
  public let isFeatured: Bool

  enum CodingKeys: String, CodingKey {
    case id
    case url
    case embedURL = "embedUrl"
    case broadcasterID = "broadcasterId"
    case broadcasterDisplayName = "broadcasterName"
    case creatorID = "creatorId"
    case creatorDisplayName = "creatorName"
    case videoID = "videoId"
    case gameID = "gameId"
    case language
    case title
    case viewCount
    case createdAt
    case thumbnailURL = "thumbnailUrl"
    case duration
    case vodOffset
    case isFeatured
  }
}
