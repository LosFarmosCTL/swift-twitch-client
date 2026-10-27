import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Applies a suspicious-user status to a viewer in a channel.
  ///
  /// Requires `moderator:manage:suspicious_users` and permission to moderate the channel.
  /// Accepts a user token or an app token with the required prior authorization.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#add-suspicious-status-to-chat-user
  /// ).
  ///
  /// - Parameters:
  ///   - userID: The viewer to monitor or restrict.
  ///   - broadcasterID: The channel broadcaster’s ID.
  ///   - status: The treatment to apply.
  ///   - moderatorID: The acting moderator’s ID; `nil` uses the authenticated user.
  public static func addSuspiciousStatusToChatUser(
    _ userID: String, in broadcasterID: String, status: SuspiciousUserTreatment,
    moderatorID: String? = nil
  ) -> HelixEndpoint<
    SuspiciousUserStatus, SuspiciousUserStatus, HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "POST", path: "moderation/suspicious_users",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("moderator_id", moderatorID ?? credentials.userID),
        ]
      }, body: { _ in ["user_id": userID, "status": status.rawValue] },
      makeResponse: { try $0.requireFirst() })
  }

  /// Removes a viewer’s suspicious-user treatment in a channel.
  ///
  /// Requires `moderator:manage:suspicious_users` and permission to moderate the channel.
  /// Accepts a user token or an app token with the required prior authorization.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#remove-suspicious-status-from-chat-user
  /// ).
  ///
  /// - Parameters:
  ///   - userID: The viewer whose treatment should be removed.
  ///   - broadcasterID: The channel broadcaster’s ID.
  ///   - moderatorID: The acting moderator’s ID; `nil` uses the authenticated user.
  public static func removeSuspiciousStatusFromChatUser(
    _ userID: String, in broadcasterID: String, moderatorID: String? = nil
  ) -> HelixEndpoint<
    SuspiciousUserStatus, SuspiciousUserStatus, HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "DELETE", path: "moderation/suspicious_users",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("moderator_id", moderatorID ?? credentials.userID),
          ("user_id", userID),
        ]
      }, makeResponse: { try $0.requireFirst() })
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
@MemberwiseInit(.public)
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

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case broadcasterID = "broadcasterId"
    case moderatorID = "moderatorId"
    case updatedAt, status, types
  }
}
