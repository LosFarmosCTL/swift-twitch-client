import Foundation

extension HelixEndpoint {
  /// Gets the authenticated broadcaster’s channel editors.
  ///
  /// With a user access token, requires `channel:read:editors`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/channels/#get-channel-editors
  /// ) for request limits and account requirements.
  public static func getChannelEditors()
    -> HelixEndpoint<[Editor]>
  {
    .init(
      method: "GET", path: "channels/editors",
      authentication: .user,
      queryItems: { credentials in
        [("broadcaster_id", try credentials.requireUser().id)]
      },
      responseType: Editor.self, makeResponse: { $0.data })
  }
}

/// An account authorized to edit a broadcaster’s channel.
public struct Editor: Decodable, Sendable {
  /// The Twitch user ID.
  public let userID: String
  /// The user’s display name.
  public let userDisplayName: String
  /// The time the resource was created.
  public let createdAt: Date

  /// Creates an `Editor` value.
  public init(
    userID: String,
    userDisplayName: String,
    createdAt: Date
  ) {
    self.userID = userID
    self.userDisplayName = userDisplayName
    self.createdAt = createdAt
  }

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userDisplayName = "userName"
    case createdAt
  }
}
