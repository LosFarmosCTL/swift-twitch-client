import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets a channel’s ongoing Guest Star session.
  ///
  /// With a user access token, requires `channel:read:guest_star` or
  /// `channel:manage:guest_star` or `moderator:read:guest_star` or
  /// `moderator:manage:guest_star`. A guest accessing the session must be invited or
  /// assigned a slot.
  ///
  /// The moderator ID must identify the broadcaster or a channel moderator and match the
  /// token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-guest-star-session
  /// ) for request limits and account requirements.
  ///
  /// Executing this endpoint requires a session in the response. An empty data array
  /// throws `HelixError.noDataInResponse` rather than yielding an optional session.
  ///
  /// - Parameters:
  ///   - broadcasterID: The broadcaster’s Twitch user ID; `nil` uses the executing
  ///     client’s authenticated user ID.
  ///   - moderatorID: The moderator’s Twitch user ID; `nil` uses the executing client’s
  ///     authenticated user ID.
  public static func getGuestStarSession(
    broadcasterID: String? = nil,
    moderatorID: String? = nil
  ) -> HelixEndpoint<
    GuestStarSession, GuestStarSession,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "guest_star/session",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID ?? credentials.userID),
          ("moderator_id", moderatorID ?? credentials.userID),
        ]
      },
      makeResponse: { response in
        let session = try response.requireFirst()

        return session
      })
  }
}

/// A Guest Star session and its participating guests.
@MemberwiseInit(.public)
public struct GuestStarSession: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The Guest Star guests.
  public let guests: [GuestStarGuest]
}

/// A guest’s slot assignment, media settings, and session timing.
@MemberwiseInit(.public)
public struct GuestStarGuest: Decodable, Sendable {
  /// The identifier of the slot.
  public let slotID: String
  /// The Twitch user ID.
  public let userID: String
  /// The user’s display name.
  public let userDisplayName: String
  /// The user’s login name.
  public let userLogin: String
  /// Whether the guest is visible in the host’s browser source.
  public let isLive: Bool
  /// The host’s volume setting for the guest, from 0 to 100.
  public let volume: Int
  /// The time the guest was assigned to the slot.
  public let assignedAt: Date
  /// The audio settings.
  public let audioSettings: GuestStarMediaSettings
  /// The video settings.
  public let videoSettings: GuestStarMediaSettings

  enum CodingKeys: String, CodingKey {
    case slotID = "slotId"
    case userID = "userId"
    case userDisplayName
    case userLogin
    case isLive
    case volume
    case assignedAt
    case audioSettings
    case videoSettings
  }
}

/// A Guest Star media device’s availability and host and guest enablement.
@MemberwiseInit(.public)
public struct GuestStarMediaSettings: Decodable, Sendable {
  /// Whether the host has enabled this media, when provided.
  public let isHostEnabled: Bool?
  /// Whether the guest has enabled this media, when provided.
  public let isGuestEnabled: Bool?
  /// Whether the resource is available.
  public let isAvailable: Bool
}
