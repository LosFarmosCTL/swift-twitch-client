import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets the authenticated broadcaster’s channel editors.
  ///
  /// With a user access token, requires `channel:read:editors`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-channel-editors
  /// ) for request limits and account requirements.
  public static func getChannelEditors()
    -> HelixEndpoint<[Editor], Editor, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "GET", path: "channels/editors",
      queryItems: { credentials in
        [("broadcaster_id", credentials.userID)]
      },
      makeResponse: { $0.data })
  }
}

/// An account authorized to edit a broadcaster’s channel.
@MemberwiseInit(.public)
public struct Editor: Decodable, Sendable {
  /// The Twitch user ID.
  public let userID: String
  /// The user’s display name.
  public let userDisplayName: String
  /// The time the resource was created.
  public let createdAt: Date

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userDisplayName = "userName"
    case createdAt
  }
}
