import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets the channels moderated by the authenticated user.
  ///
  /// With a user access token, requires `user:read:moderated_channels`. App tokens have
  /// additional grant requirements described in the reference.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-moderated-channels
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `user_id`.
  ///
  /// - Parameters:
  ///   - userID: The acting user ID. Required with app tokens; otherwise defaults
  ///     to the user token’s identity.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - afterCursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields matching items and a pagination cursor when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func getModeratedChannels(
    limit: Int? = nil,
    after afterCursor: String? = nil,
    userID: String? = nil
  ) -> HelixEndpoint<
    (channels: [ModeratedChannel], cursor: String?), ModeratedChannel,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "moderation/channels",
      authentication: .either,
      queryItems: { credentials in
        [
          (
            "user_id",
            try credentials.resolveUserID(
              userID, parameter: "user_id", matchingToken: true)
          ),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ]
      }, makeResponse: { ($0.data, $0.pagination?.cursor) }
    )
  }
}

/// A channel in which the authenticated user is a moderator.
@MemberwiseInit(.public)
public struct ModeratedChannel: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The account’s login name.
  public let login: String
  /// The display name shown on Twitch.
  public let displayName: String

  enum CodingKeys: String, CodingKey {
    case id = "broadcasterId"
    case login = "broadcasterLogin"
    case displayName = "broadcasterName"
  }
}
