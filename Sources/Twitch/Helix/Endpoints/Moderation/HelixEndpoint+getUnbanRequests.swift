import Foundation

extension HelixEndpoint {
  /// Gets a channel’s unban requests filtered by status.
  ///
  /// Requires a user token with `moderator:read:unban_requests` or
  /// `moderator:manage:unban_requests`. The moderator ID must match the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/moderation/#get-unban-requests
  /// ).
  ///
  /// - Parameters:
  ///   - broadcasterID: The channel broadcaster’s ID.
  ///   - status: The request status to retrieve.
  ///   - userID: An optional requestor ID to filter by.
  ///   - limit: The page size; `nil` uses Twitch’s default.
  ///   - cursor: The next-page cursor, if any.
  /// - Returns: Requests and the next-page cursor.
  public static func getUnbanRequests(
    in broadcasterID: String, status: UnbanRequestStatus, userID: String? = nil,
    limit: Int? = nil, after cursor: String? = nil
  ) -> HelixEndpoint<UnbanRequestsResponse> {
    .init(
      method: "GET", path: "moderation/unban_requests",
      authentication: .user,
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("moderator_id", try credentials.requireUserID(parameter: "moderator_id")),
          ("status", status.rawValue), ("user_id", userID),
          ("first", limit.map(String.init)), ("after", cursor),
        ]
      }, responseType: UnbanRequest.self,
      makeResponse: {
        UnbanRequestsResponse(requests: $0.data, cursor: $0.pagination?.cursor)
      })
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
  public let moderatorID: String?
  /// The resolving moderator’s login name.
  public let moderatorLogin: String?
  /// The resolving moderator’s display name.
  public let moderatorDisplayName: String?
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

  /// Creates a `UnbanRequest` value.
  public init(
    id: String,
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    moderatorID: String? = nil,
    moderatorLogin: String? = nil,
    moderatorDisplayName: String? = nil,
    userID: String,
    userLogin: String,
    userDisplayName: String,
    text: String,
    status: String,
    createdAt: Date,
    resolvedAt: Date? = nil,
    resolutionText: String? = nil
  ) {
    self.id = id
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.moderatorID = moderatorID
    self.moderatorLogin = moderatorLogin
    self.moderatorDisplayName = moderatorDisplayName
    self.userID = userID
    self.userLogin = userLogin
    self.userDisplayName = userDisplayName
    self.text = text
    self.status = status
    self.createdAt = createdAt
    self.resolvedAt = resolvedAt
    self.resolutionText = resolutionText
  }

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

/// A page of unban requests.
public struct UnbanRequestsResponse: Sendable {
  /// The requests on this page.
  public let requests: [UnbanRequest]
  /// The next-page cursor, if Twitch returned one.
  public let cursor: String?

  /// Creates a `UnbanRequestsResponse` value.
  public init(
    requests: [UnbanRequest] = [],
    cursor: String? = nil
  ) {
    self.requests = requests
    self.cursor = cursor
  }
}
