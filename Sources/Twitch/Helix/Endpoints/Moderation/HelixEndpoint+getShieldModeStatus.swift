import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets a channel’s Shield Mode state.
  ///
  /// With a user access token, requires `moderator:read:shield_mode` or
  /// `moderator:manage:shield_mode`. App tokens have additional grant requirements
  /// described in the reference. The moderator ID must match the token’s user, who must
  /// be the broadcaster or a moderator of the channel.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-shield-mode-status
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `moderator_id`.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  public static func getShieldModeStatus(of broadcasterID: String)
    -> HelixEndpoint<
      ShieldModeStatus, ShieldModeStatus,
      HelixEndpointResponseTypes.Normal
    >
  {
    .init(
      method: "GET", path: "moderation/shield_mode",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("moderator_id", credentials.userID),
        ]
      },
      makeResponse: {
        let status = try $0.requireFirst()

        return status
      })
  }
}

/// A channel’s Shield Mode state and the moderator who last changed it.
@MemberwiseInit(.public)
public struct ShieldModeStatus: Decodable, Sendable {
  /// Whether the resource is active.
  public let isActive: Bool
  /// The Twitch user ID of the moderator.
  public let moderatorID: String
  /// The display name of the moderator.
  public let moderatorDisplayName: String
  /// The login name of the moderator.
  public let moderatorLogin: String

  /// The last activation time, when provided.
  @InitRaw(default: nil, type: Date?.self)
  @NilOnTypeMismatch public var lastActivatedAt: Date?

  enum CodingKeys: String, CodingKey {
    case moderatorID = "moderatorId"
    case moderatorDisplayName = "moderatorName"
    case moderatorLogin
    case isActive
    case lastActivatedAt
  }
}
