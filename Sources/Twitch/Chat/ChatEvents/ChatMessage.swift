import Foundation

public struct ChatMessage {
  public let rawIRCTags: [String: String]
  public let rawIRCMessage: String

  public let message: String
  public let id: String
  public let emotes: [ChatEmote]
  public let flags: String  // TODO: this contains automod flags, parse them

  public let channelId: String
  public let channelName: String

  public let senderId: String
  public let senderLogin: String
  public let senderDisplayName: String

  public let badges: [ChatBadge]
  public let color: String

  public let replyingTo: ChatReplyParent?

  public let firstMessage: Bool
  public let clientNonce: String?

  public let timestamp: Date

  @available(
    *, deprecated,
    message:
      "Deprecated by Twitch, might disappear at any point. Check using `badges` instead."
  ) public let subscriber: Bool?
  @available(
    *, deprecated,
    message:
      "Deprecated by Twitch, might disappear at any point. Check using `badges` instead."
  ) public let mod: Bool?
  @available(
    *, deprecated,
    message:
      "Not officially deprecated by twitch, but if possible check using `badges` instead."
  ) public let turbo: Bool

  internal init(from message: PRIVMSG) {
    self.rawIRCTags = message.rawIRCTags
    self.rawIRCMessage = message.rawIRCMessage

    self.message = message.message
    self.id = message.id
    self.emotes = message.emotes.components(separatedBy: "/").compactMap(
      ChatEmote.init)
    self.flags = message.flags

    self.channelId = message.roomId
    self.channelName = message.channelName

    self.senderId = message.userId
    self.senderLogin = message.senderLogin
    self.senderDisplayName = message.displayName

    let badgeInfo = message.badgeInfo.components(separatedBy: ",")
    self.badges = message.badges.components(separatedBy: ",").compactMap {
      ChatBadge(from: $0, with: badgeInfo)
    }
    self.color = message.color

    // TODO
    self.replyingTo = nil

    self.firstMessage = message.firstMsg ?? false
    self.clientNonce = message.clientNonce

    self.timestamp = message.tmiSentTs

    self.subscriber = message.subscriber
    self.mod = message.mod
    self.turbo = message.turbo ?? false
  }
}
