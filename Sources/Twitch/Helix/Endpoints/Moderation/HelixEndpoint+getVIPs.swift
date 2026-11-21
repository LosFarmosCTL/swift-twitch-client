import Foundation

extension HelixEndpoint {
  /// Gets the authenticated broadcaster’s channel VIPs.
  ///
  /// With a user access token, requires `channel:read:vips` or `channel:manage:vips`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/moderation/#get-vips
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `broadcaster_id`.
  ///
  /// - Parameters:
  ///   - userIDs: The user IDs to include in the request. Defaults to `[]`.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - cursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields matching items and a pagination cursor when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func getVIPs(
    userIDs: [String] = [],
    limit: Int? = nil,
    after cursor: String? = nil
  ) -> HelixEndpoint<VIPsResponse> {
    .init(
      method: "GET", path: "channels/vips",
      authentication: .user,
      queryItems: { credentials in
        [
          ("broadcaster_id", try credentials.requireUser().id),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ] + userIDs.map { ("user_id", $0) }
      }, responseType: VIP.self,
      makeResponse: { VIPsResponse(vips: $0.data, cursor: $0.pagination?.cursor) })
  }
}

/// An account with VIP status in a channel.
public struct VIP: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The account’s login name.
  public let login: String
  /// The display name shown on Twitch.
  public let displayName: String

  /// Creates a `VIP` value.
  public init(
    id: String,
    login: String,
    displayName: String
  ) {
    self.id = id
    self.login = login
    self.displayName = displayName
  }

  enum CodingKeys: String, CodingKey {
    case id = "userId"
    case login = "userLogin"
    case displayName = "userName"
  }
}

/// A page of channel VIPs.
public struct VIPsResponse: Sendable {
  /// The vips on this page.
  public let vips: [VIP]
  /// The next-page cursor, if Twitch returned one.
  public let cursor: String?

  /// Creates a `VIPsResponse` value.
  public init(
    vips: [VIP] = [],
    cursor: String? = nil
  ) {
    self.vips = vips
    self.cursor = cursor
  }
}
