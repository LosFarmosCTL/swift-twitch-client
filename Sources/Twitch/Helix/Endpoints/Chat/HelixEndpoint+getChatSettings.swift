import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets a channel’s chat restrictions and authorized moderator settings.
  ///
  /// Accepts a user or app access token without an additional endpoint scope. Reading
  /// non-moderator chat delay also requires `moderator:read:chat_settings`, with
  /// `moderatorID` matching a channel moderator’s token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-chat-settings
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: A channel moderator’s user ID, matching the user access token. Omit
  ///     it to exclude non-moderator chat delay information.
  public static func getChatSettings(
    of broadcasterID: String, moderatorID: String? = nil
  ) -> HelixEndpoint<ChatSettings, ChatSettings, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "chat/settings",
      queryItems: { _ in
        [("broadcaster_id", broadcasterID), ("moderator_id", moderatorID)]
      },
      makeResponse: {
        let settings = try $0.requireFirst()

        return settings
      })
  }
}

/// A channel’s chat restrictions and any moderator-visible delay settings.
@MemberwiseInit(.public)
public struct ChatSettings: Decodable, Sendable {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The required delay between a user’s messages, in seconds, when slow mode is enabled.
  public let slowModeWaitTime: Int?
  /// The required following duration, in minutes, when follower-only mode is enabled.
  public let followerModeDuration: Int?
  /// Whether chat is restricted to subscribers.
  public let subscriberMode: Bool
  /// Whether chat is restricted to emotes.
  public let emoteMode: Bool
  /// Whether duplicate chat messages are restricted.
  public let uniqueChatMode: Bool

  /// The delay applied to non-moderator messages, in seconds. `nil` means Twitch omitted
  /// the duration, including when the request lacks moderator authorization.
  public let nonModeratorChatDelay: Int?

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case slowModeWaitTime
    case followerModeDuration
    case subscriberMode
    case emoteMode
    case uniqueChatMode

    case nonModeratorChatDelayDuration
  }

  /// Decodes chat settings and the optional duration fields returned by Twitch.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.broadcasterID = try container.decode(String.self, forKey: .broadcasterID)
    self.slowModeWaitTime = try container.decodeIfPresent(
      Int.self, forKey: .slowModeWaitTime)
    self.followerModeDuration = try container.decodeIfPresent(
      Int.self, forKey: .followerModeDuration)

    self.subscriberMode = try container.decode(Bool.self, forKey: .subscriberMode)
    self.emoteMode = try container.decode(Bool.self, forKey: .emoteMode)
    self.uniqueChatMode = try container.decode(Bool.self, forKey: .uniqueChatMode)

    self.nonModeratorChatDelay = try container.decodeIfPresent(
      Int.self, forKey: .nonModeratorChatDelayDuration)
  }
}
