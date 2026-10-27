import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets the terms blocked by a channel’s moderation settings.
  ///
  /// With a user access token, requires `moderator:read:blocked_terms` or
  /// `moderator:manage:blocked_terms`. App tokens have additional grant requirements
  /// described in the reference. The moderator ID must match the token’s user, who must
  /// be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-blocked-terms
  /// ) for request limits and account requirements.
  ///
  /// Omit `moderatorID` to use the user token’s identity. App tokens require it explicitly.
  ///
  /// - Parameters:
  ///   - moderatorID: The acting user ID. Required with app tokens; otherwise defaults
  ///     to the user token’s identity.
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - afterCursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields `(terms: [BlockedTerm], cursor: String?)` when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func getBlockedTerms(
    in broadcasterID: String,
    limit: Int? = nil,
    after afterCursor: String? = nil,
    moderatorID: String? = nil
  ) -> HelixEndpoint<
    (terms: [BlockedTerm], cursor: String?), BlockedTerm,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "moderation/blocked_terms",
      authentication: .either,
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          (
            "moderator_id",
            try credentials.resolveUserID(
              moderatorID, parameter: "moderator_id", matchingToken: true)
          ),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ]
      },
      makeResponse: {
        ($0.data, $0.pagination?.cursor)
      })
  }
}

/// A term blocked by a channel’s moderation settings.
@MemberwiseInit(.public)
public struct BlockedTerm: Decodable, Sendable {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The Twitch user ID of the moderator.
  public let moderatorID: String

  /// The identifier assigned by Twitch.
  public let id: String
  /// The text content.
  public let text: String

  /// The time the resource was created.
  public let createdAt: Date
  /// The time the resource was last updated.
  public let updatedAt: Date

  /// The expiration time, when provided.
  public let expiresAt: Date?

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case moderatorID = "moderatorId"

    case id, text, createdAt, updatedAt, expiresAt
  }
}
