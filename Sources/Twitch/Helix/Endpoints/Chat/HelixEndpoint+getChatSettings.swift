import Foundation

extension HelixEndpoint {
  /// Gets a channel’s chat restrictions and authorized moderator settings.
  ///
  /// Accepts a user or app access token without an additional endpoint scope. Reading
  /// non-moderator chat delay also requires `moderator:read:chat_settings` or
  /// `moderator:manage:chat_settings`, with
  /// `moderatorID` matching a channel moderator’s token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/chat/#get-chat-settings
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - moderatorID: A channel moderator’s user ID, matching the user access token. Omit
  ///     it to exclude non-moderator chat delay information.
  public static func getChatSettings(
    of broadcasterID: String, moderatorID: String? = nil
  ) -> HelixEndpoint<ChatSettings> {
    .init(
      method: "GET", path: "chat/settings",
      authentication: .either,
      queryItems: { _ in
        [("broadcaster_id", broadcasterID), ("moderator_id", moderatorID)]
      },
      responseType: ChatSettings.self,
      makeResponse: {
        let settings = try $0.requireFirst()

        return settings
      })
  }
}

/// A channel’s chat restrictions and any moderator-visible delay settings.
public struct ChatSettings: Decodable, Sendable {
  /// The acting moderator’s user ID, when returned by Twitch.
  public let moderatorID: String?
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// Whether slow mode is enabled. Independent of the configured wait time.
  public let slowMode: Bool
  /// Whether follower-only mode is enabled. A zero-minute duration still permits this mode.
  public let followerMode: Bool
  /// Whether non-moderator delay is enabled, if Twitch returned moderator-only data.
  public let nonModeratorChatDelay: Bool?
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
  public let nonModeratorChatDelayDuration: Int?

  /// Creates a `ChatSettings` value.
  public init(
    moderatorID: String? = nil,
    broadcasterID: String,
    slowMode: Bool = false,
    followerMode: Bool = false,
    nonModeratorChatDelay: Bool? = nil,
    slowModeWaitTime: Int? = nil,
    followerModeDuration: Int? = nil,
    subscriberMode: Bool,
    emoteMode: Bool,
    uniqueChatMode: Bool,
    nonModeratorChatDelayDuration: Int? = nil
  ) {
    self.moderatorID = moderatorID
    self.broadcasterID = broadcasterID
    self.slowMode = slowMode
    self.followerMode = followerMode
    self.nonModeratorChatDelay = nonModeratorChatDelay
    self.slowModeWaitTime = slowModeWaitTime
    self.followerModeDuration = followerModeDuration
    self.subscriberMode = subscriberMode
    self.emoteMode = emoteMode
    self.uniqueChatMode = uniqueChatMode
    self.nonModeratorChatDelayDuration = nonModeratorChatDelayDuration
  }

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case moderatorID = "moderatorId"
    case slowMode, followerMode
    case nonModeratorChatDelay
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
    self.moderatorID = try container.decodeIfPresent(String.self, forKey: .moderatorID)
    self.slowMode = try container.decode(Bool.self, forKey: .slowMode)
    self.followerMode = try container.decode(Bool.self, forKey: .followerMode)
    self.nonModeratorChatDelay = try container.decodeIfPresent(
      Bool.self, forKey: .nonModeratorChatDelay)
    self.slowModeWaitTime = try container.decodeIfPresent(
      Int.self, forKey: .slowModeWaitTime)
    self.followerModeDuration = try container.decodeIfPresent(
      Int.self, forKey: .followerModeDuration)

    self.subscriberMode = try container.decode(Bool.self, forKey: .subscriberMode)
    self.emoteMode = try container.decode(Bool.self, forKey: .emoteMode)
    self.uniqueChatMode = try container.decode(Bool.self, forKey: .uniqueChatMode)

    self.nonModeratorChatDelayDuration = try container.decodeIfPresent(
      Int.self, forKey: .nonModeratorChatDelayDuration)
  }
}
