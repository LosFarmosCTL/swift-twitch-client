import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets the channel’s mod-pinned message, or `nil` if none is pinned.
  ///
  /// Requires `moderator:read:chat_messages` or `moderator:manage:chat_messages`.
  /// App tokens require additional prior user and channel grants.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-pinned-chat-message
  /// ).
  ///
  /// - Parameters:
  ///   - broadcasterID: The channel broadcaster’s user ID.
  ///   - moderatorID: The acting moderator’s ID; `nil` uses the authenticated user.
  public static func getPinnedChatMessage(
    in broadcasterID: String, moderatorID: String? = nil
  ) -> HelixEndpoint<
    PinnedChatMessage?, PinnedChatMessage, HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "chat/pins",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("moderator_id", moderatorID ?? credentials.userID),
        ]
      }, makeResponse: { $0.data.first })
  }

  /// Pins a chat message, replacing any existing mod-pinned message in the channel.
  ///
  /// Requires `moderator:manage:chat_messages`. App tokens require additional prior grants.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#pin-chat-message
  /// ).
  ///
  /// - Parameters:
  ///   - messageID: The message to pin.
  ///   - broadcasterID: The channel broadcaster’s user ID.
  ///   - durationSeconds: A duration from 30 through 1800 seconds; `nil` pins until stream end.
  ///   - moderatorID: The acting moderator’s ID; `nil` uses the authenticated user.
  public static func pinChatMessage(
    _ messageID: String, in broadcasterID: String,
    durationSeconds: Int? = nil, moderatorID: String? = nil
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "PUT", path: "chat/pins",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("moderator_id", moderatorID ?? credentials.userID),
          ("message_id", messageID),
          ("duration_seconds", durationSeconds.map(String.init)),
        ]
      })
  }

  /// Changes how long an existing mod-pinned message remains pinned, starting from now.
  ///
  /// Requires `moderator:manage:chat_messages`. App tokens require additional prior grants.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#update-pinned-chat-message
  /// ).
  ///
  /// - Parameters:
  ///   - messageID: The pinned message to update.
  ///   - broadcasterID: The channel broadcaster’s user ID.
  ///   - durationSeconds: A duration from 30 through 1800 seconds; `nil` pins until stream end.
  ///   - moderatorID: The acting moderator’s ID; `nil` uses the authenticated user.
  public static func updatePinnedChatMessage(
    _ messageID: String, in broadcasterID: String,
    durationSeconds: Int? = nil, moderatorID: String? = nil
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "PATCH", path: "chat/pins",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("moderator_id", moderatorID ?? credentials.userID),
          ("message_id", messageID),
          ("duration_seconds", durationSeconds.map(String.init)),
        ]
      })
  }

  /// Unpins the specified mod-pinned chat message.
  ///
  /// Requires `moderator:manage:chat_messages`. App tokens require additional prior grants.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#unpin-chat-message
  /// ).
  ///
  /// - Parameters:
  ///   - messageID: The message to unpin.
  ///   - broadcasterID: The channel broadcaster’s user ID.
  ///   - moderatorID: The acting moderator’s ID; `nil` uses the authenticated user.
  public static func unpinChatMessage(
    _ messageID: String, in broadcasterID: String, moderatorID: String? = nil
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "DELETE", path: "chat/pins",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("moderator_id", moderatorID ?? credentials.userID),
          ("message_id", messageID),
        ]
      })
  }
}

/// A mod-pinned chat message, its author, and its pinning metadata.
@MemberwiseInit(.public)
public struct PinnedChatMessage: Decodable, Sendable {
  /// The pinned message ID.
  public let messageID: String
  /// The broadcaster’s user ID.
  public let broadcasterID: String
  /// The message author’s user ID.
  public let senderID: String
  /// The message author’s login name.
  public let senderLogin: String
  /// The message author’s display name.
  public let senderDisplayName: String
  /// The user ID of the moderator who pinned the message.
  public let pinnedByID: String
  /// The pinning moderator’s login name.
  public let pinnedByLogin: String
  /// The pinning moderator’s display name.
  public let pinnedByDisplayName: String
  /// The message text and typed fragments.
  public let message: ChannelChatMessageEvent.Message
  /// When the message was pinned.
  public let startsAt: Date
  /// When the pin expires; `nil` means the end of the stream.
  public let endsAt: Date?
  /// When the pin was last updated.
  public let updatedAt: Date

  enum CodingKeys: String, CodingKey {
    case messageID = "messageId"
    case broadcasterID = "broadcasterId"
    case senderID = "senderUserId"
    case senderLogin = "senderUserLogin"
    case senderDisplayName = "senderUserName"
    case pinnedByID = "pinnedByUserId"
    case pinnedByLogin = "pinnedByUserLogin"
    case pinnedByDisplayName = "pinnedByUserName"
    case message, startsAt, endsAt, updatedAt
  }
}
