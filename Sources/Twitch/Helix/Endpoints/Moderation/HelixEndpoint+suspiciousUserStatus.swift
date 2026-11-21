import Foundation

extension HelixEndpoint {
  /// Applies a suspicious-user status to a viewer in a channel.
  ///
  /// Requires `moderator:manage:suspicious_users` and permission to moderate the channel.
  /// Accepts a user token or an app token with the required prior authorization.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/moderation/#add-suspicious-status-to-chat-user
  /// ).
  ///
  /// - Parameters:
  ///   - userID: The viewer to monitor or restrict.
  ///   - broadcasterID: The channel broadcaster’s ID.
  ///   - status: The treatment to apply.
  ///   - moderatorID: The acting moderator’s ID; `nil` uses the user token’s identity.
  ///     Required for app tokens.
  public static func addSuspiciousStatusToChatUser(
    _ userID: String, in broadcasterID: String, status: SuspiciousUserTreatment,
    moderatorID: String? = nil
  ) -> HelixEndpoint<SuspiciousUserStatus> {
    .init(
      method: "POST", path: "moderation/suspicious_users",
      authentication: .either,
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          (
            "moderator_id",
            try credentials.resolveUserID(
              moderatorID, parameter: "moderator_id", matchingToken: true)
          ),
        ]
      }, body: { _ in ["user_id": userID, "status": status.rawValue] },
      responseType: SuspiciousUserStatus.self, makeResponse: { try $0.requireFirst() })
  }

  /// Removes a viewer’s suspicious-user treatment in a channel.
  ///
  /// Requires `moderator:manage:suspicious_users` and permission to moderate the channel.
  /// Accepts a user token or an app token with the required prior authorization.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/moderation/#remove-suspicious-status-from-chat-user
  /// ).
  ///
  /// - Parameters:
  ///   - userID: The viewer whose treatment should be removed.
  ///   - broadcasterID: The channel broadcaster’s ID.
  ///   - moderatorID: The acting moderator’s ID; `nil` uses the user token’s identity.
  ///     Required for app tokens.
  public static func removeSuspiciousStatusFromChatUser(
    _ userID: String, in broadcasterID: String, moderatorID: String? = nil
  ) -> HelixEndpoint<SuspiciousUserStatus> {
    .init(
      method: "DELETE", path: "moderation/suspicious_users",
      authentication: .either,
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          (
            "moderator_id",
            try credentials.resolveUserID(
              moderatorID, parameter: "moderator_id", matchingToken: true)
          ),
          ("user_id", userID),
        ]
      }, responseType: SuspiciousUserStatus.self, makeResponse: { try $0.requireFirst() })
  }
}

/// Treatments a moderator can apply to a suspicious viewer.
public enum SuspiciousUserTreatment: String, Sendable {
  /// Monitors the viewer’s messages. Encoded as `"ACTIVE_MONITORING"`.
  case activeMonitoring = "ACTIVE_MONITORING"
  /// Restricts the viewer’s messages. Encoded as `"RESTRICTED"`.
  case restricted = "RESTRICTED"
}

/// The result of changing a viewer’s suspicious-user treatment.
public struct SuspiciousUserStatus: Decodable, Sendable {
  /// The viewer’s user ID.
  public let userID: String
  /// The broadcaster’s user ID.
  public let broadcasterID: String
  /// The last acting moderator’s user ID.
  public let moderatorID: String
  /// When the treatment was last updated.
  public let updatedAt: Date
  /// The treatment, including `NO_TREATMENT` after removal.
  public let status: String
  /// Reasons for suspicion, such as `MANUALLY_ADDED` or `DETECTED_BAN_EVADER`.
  public let types: [String]

  /// Creates a `SuspiciousUserStatus` value.
  public init(
    userID: String,
    broadcasterID: String,
    moderatorID: String,
    updatedAt: Date,
    status: String,
    types: [String] = []
  ) {
    self.userID = userID
    self.broadcasterID = broadcasterID
    self.moderatorID = moderatorID
    self.updatedAt = updatedAt
    self.status = status
    self.types = types
  }

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case broadcasterID = "broadcasterId"
    case moderatorID = "moderatorId"
    case updatedAt, status, types
  }
}
