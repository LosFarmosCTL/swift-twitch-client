import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets pending invitations to a Guest Star session.
  ///
  /// With a user access token, requires `channel:read:guest_star` or
  /// `channel:manage:guest_star` or `moderator:read:guest_star` or
  /// `moderator:manage:guest_star`. Twitch requires the broadcaster ID to match the
  /// token’s user.
  ///
  /// The moderator ID must identify the broadcaster or a channel moderator and match the
  /// token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-guest-star-invites
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - broadcasterID: The broadcaster’s Twitch user ID; `nil` uses the executing
  ///     client’s authenticated user ID.
  ///   - moderatorID: The moderator’s Twitch user ID; `nil` uses the executing client’s
  ///     authenticated user ID.
  ///   - sessionID: The identifier of the session.
  public static func getGuestStarInvites(
    broadcasterID: String? = nil,
    moderatorID: String? = nil,
    sessionID: String
  ) -> HelixEndpoint<
    [GuestStarInvite], GuestStarInvite,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "guest_star/invites",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID ?? credentials.userID),
          ("moderator_id", moderatorID ?? credentials.userID),
          ("session_id", sessionID),
        ]
      },
      makeResponse: { $0.data })
  }
}

/// A pending Guest Star invitation and the invited user’s readiness.
@MemberwiseInit(.public)
public struct GuestStarInvite: Decodable, Sendable {
  /// The Twitch user ID.
  public let userID: String
  /// The time the guest was invited.
  public let invitedAt: Date
  /// Whether the invited guest is awaiting a connection, ready, or otherwise unavailable.
  public let status: GuestStarInviteStatus
  /// Whether video is enabled.
  public let isVideoEnabled: Bool
  /// Whether audio is enabled.
  public let isAudioEnabled: Bool
  /// Whether the guest has a video device available.
  public let isVideoAvailable: Bool
  /// Whether the guest has an audio device available.
  public let isAudioAvailable: Bool

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case invitedAt
    case status
    case isVideoEnabled
    case isAudioEnabled
    case isVideoAvailable
    case isAudioAvailable
  }
}

/// An invited guest’s progress through the waiting room before joining a session.
public enum GuestStarInviteStatus: String, Codable, Sendable {
  /// The guest has been invited but has not accepted. Encoded as `"INVITED"`.
  case invited = "INVITED"
  /// The guest has accepted the invitation. Encoded as `"ACCEPTED"`.
  case accepted = "ACCEPTED"
  /// The guest is ready to join the session. Encoded as `"READY"`.
  case ready = "READY"
}
