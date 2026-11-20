import Foundation

/// A version 1 EventSub channel moderation notification.
public struct ChannelModerateV1Event: Event {
  internal let moderation: ChannelModerateEvent

  /// The Twitch user ID of the broadcaster.
  public var broadcasterID: String { moderation.broadcasterID }
  /// The login name of the broadcaster.
  public var broadcasterLogin: String { moderation.broadcasterLogin }
  /// The display name of the broadcaster.
  public var broadcasterDisplayName: String { moderation.broadcasterDisplayName }
  /// The Twitch user ID of the source broadcaster, when provided.
  public var sourceBroadcasterID: String? { moderation.sourceBroadcasterID }
  /// The login name of the source broadcaster, when provided.
  public var sourceBroadcasterLogin: String? { moderation.sourceBroadcasterLogin }
  /// The display name of the source broadcaster, when provided.
  public var sourceBroadcasterDisplayName: String? { moderation.sourceBroadcasterDisplayName }
  /// The Twitch user ID of the moderator.
  public var moderatorID: String { moderation.moderatorID }
  /// The login name of the moderator.
  public var moderatorLogin: String { moderation.moderatorLogin }
  /// The display name of the moderator.
  public var moderatorDisplayName: String { moderation.moderatorDisplayName }
  /// The action and its details. Warning actions are exclusive to version 2.
  public var action: ChannelModerateEvent.Action { moderation.action }

  /// Decodes a version 1 moderation event and its action-specific payload.
  public init(from decoder: any Decoder) throws {
    let moderation = try ChannelModerateEvent(from: decoder)
    if case .warn = moderation.action {
      throw DecodingError.dataCorrupted(
        .init(codingPath: decoder.codingPath, debugDescription: "Warnings require version 2."))
    }
    self.moderation = moderation
  }
}
