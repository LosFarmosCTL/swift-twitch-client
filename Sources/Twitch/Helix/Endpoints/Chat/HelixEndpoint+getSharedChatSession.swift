import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets a channel’s active shared chat session, or `nil` when it is not in one.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-shared-chat-session
  /// ).
  ///
  /// - Parameter broadcasterID: The channel broadcaster’s user ID.
  public static func getSharedChatSession(
    for broadcasterID: String
  ) -> HelixEndpoint<
    SharedChatSession?, SharedChatSession, HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "shared_chat/session",
      authentication: .either,
      queryItems: { _ in [("broadcaster_id", broadcasterID)] },
      makeResponse: { $0.data.first })
  }
}

/// An active shared chat session and the channels participating in it.
@MemberwiseInit(.public)
public struct SharedChatSession: Decodable, Sendable {
  /// The session ID.
  public let sessionID: String
  /// The host broadcaster’s user ID.
  public let hostBroadcasterID: String
  /// The participating channels.
  public let participants: [Participant]
  /// When the session was created.
  public let createdAt: Date
  /// When the session was last updated.
  public let updatedAt: Date

  enum CodingKeys: String, CodingKey {
    case sessionID = "sessionId"
    case hostBroadcasterID = "hostBroadcasterId"
    case participants, createdAt, updatedAt
  }

  /// A channel participating in shared chat.
  @MemberwiseInit(.public)
  public struct Participant: Decodable, Sendable {
    /// The participating broadcaster’s user ID.
    public let broadcasterID: String

    enum CodingKeys: String, CodingKey {
      case broadcasterID = "broadcasterId"
    }
  }
}
