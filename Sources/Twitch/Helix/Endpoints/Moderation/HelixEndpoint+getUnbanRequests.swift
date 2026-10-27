import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets a channel’s unban requests filtered by status.
  ///
  /// Requires a user token with `moderator:read:unban_requests` or
  /// `moderator:manage:unban_requests`. The moderator ID must match the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-unban-requests
  /// ).
  ///
  /// - Parameters:
  ///   - broadcasterID: The channel broadcaster’s ID.
  ///   - status: The request status to retrieve.
  ///   - userID: An optional requestor ID to filter by.
  ///   - limit: The page size; `nil` uses Twitch’s default.
  ///   - afterCursor: The next-page cursor, if any.
  ///   - moderatorID: The acting moderator’s ID; `nil` uses the user token’s identity.
  ///     Required for app tokens.
  /// - Returns: Requests and the next-page cursor.
  public static func getUnbanRequests(
    in broadcasterID: String, status: UnbanRequestStatus, userID: String? = nil,
    limit: Int? = nil, after afterCursor: String? = nil, moderatorID: String? = nil
  ) -> HelixEndpoint<
    (requests: [UnbanRequest], cursor: String?), UnbanRequest,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "moderation/unban_requests",
      authentication: .user,
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          (
            "moderator_id",
            try credentials.resolveUserID(
              moderatorID, parameter: "moderator_id", matchingToken: true)
          ),
          ("status", status.rawValue), ("user_id", userID),
          ("first", limit.map(String.init)), ("after", afterCursor),
        ]
      }, makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

/// The statuses used to filter unban requests.
public enum UnbanRequestStatus: String, Sendable {
  /// The request awaits a decision.
  case pending
  /// The request was approved.
  case approved
  /// The request was denied.
  case denied
  /// The request was acknowledged.
  case acknowledged
  /// The request was cancelled. Encoded as `"canceled"`.
  case cancelled = "canceled"
}

/// A viewer’s unban request and its moderation history.
@MemberwiseInit(.public)
public struct UnbanRequest: Decodable, Sendable {
  /// The unban request ID.
  public let id: String
  /// The broadcaster’s user ID.
  public let broadcasterID: String
  /// The broadcaster’s login name.
  public let broadcasterLogin: String
  /// The broadcaster’s display name.
  public let broadcasterDisplayName: String
  /// The resolving moderator’s user ID, or an empty string if unresolved.
  public let moderatorID: String
  /// The resolving moderator’s login name.
  public let moderatorLogin: String
  /// The resolving moderator’s display name.
  public let moderatorDisplayName: String
  /// The requestor’s user ID.
  public let userID: String
  /// The requestor’s login name.
  public let userLogin: String
  /// The requestor’s display name.
  public let userDisplayName: String
  /// The viewer’s request text.
  public let text: String
  /// Twitch’s status string, such as `pending`, `approved`, or `denied`.
  public let status: String
  /// When the request was created.
  public let createdAt: Date
  /// When the request was resolved, if resolved.
  public let resolvedAt: Date?
  /// The resolver’s explanation, if any.
  public let resolutionText: String?

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterId"
    case broadcasterLogin
    case broadcasterDisplayName = "broadcasterName"
    case moderatorID = "moderatorId"
    case moderatorLogin
    case moderatorDisplayName = "moderatorName"
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case text, status, createdAt, resolvedAt, resolutionText
  }
}
