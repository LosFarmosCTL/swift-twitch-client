import Foundation

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
  /// https://dev.twitch.tv/docs/api/reference/guest-star/#get-guest-star-invites
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - sessionID: The identifier of the session.
  ///   - broadcasterID: The broadcaster’s Twitch user ID; `nil` uses the executing
  ///     client’s authenticated user ID.
  public static func getGuestStarInvites(
    sessionID: String,
    broadcasterID: String? = nil
  ) -> HelixEndpoint<[GuestStarInvite]> {
    .init(
      method: "GET", path: "guest_star/invites",
      authentication: .user,
      queryItems: { credentials in
        [
          (
            "broadcaster_id",
            try credentials.resolveUserID(broadcasterID, parameter: "broadcaster_id")
          ),
          ("moderator_id", try credentials.requireUserID(parameter: "moderator_id")),
          ("session_id", sessionID),
        ]
      },
      responseType: GuestStarInvite.self, makeResponse: { $0.data })
  }
}

/// A pending Guest Star invitation and the invited user’s readiness.
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

  /// Creates a `GuestStarInvite` value.
  public init(
    userID: String,
    invitedAt: Date,
    status: GuestStarInviteStatus,
    isVideoEnabled: Bool,
    isAudioEnabled: Bool,
    isVideoAvailable: Bool,
    isAudioAvailable: Bool
  ) {
    self.userID = userID
    self.invitedAt = invitedAt
    self.status = status
    self.isVideoEnabled = isVideoEnabled
    self.isAudioEnabled = isAudioEnabled
    self.isVideoAvailable = isVideoAvailable
    self.isAudioAvailable = isAudioAvailable
  }

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

/// An invited guest’s progress through the waiting room before joining a session,
/// preserving unfamiliar values in `rawValue`.
public struct GuestStarInviteStatus: RawRepresentable, Codable, Sendable, Hashable {
  /// The exact invite status string supplied by Twitch or the caller.
  public let rawValue: String

  /// Creates an invite status from any raw string.
  public init(rawValue: String) { self.rawValue = rawValue }

  /// Decodes an invite status from a single string.
  public init(from decoder: Decoder) throws {
    self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
  }

  /// Encodes this invite status as its raw wire string.
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(rawValue)
  }

  /// The guest has been invited but has not accepted. Encoded as `"INVITED"`.
  public static let invited = Self(rawValue: "INVITED")
  /// The guest has accepted the invitation. Encoded as `"ACCEPTED"`.
  public static let accepted = Self(rawValue: "ACCEPTED")
  /// The guest is ready to join the session. Encoded as `"READY"`.
  public static let ready = Self(rawValue: "READY")
}
