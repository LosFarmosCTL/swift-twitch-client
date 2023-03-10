public struct Whisper {
  public let rawIRCTags: [String: String]
  public let rawIRCMessage: String

  public let message: String
  public let messageId: String
  public let emotes: [ChatEmote]

  public let threadId: String

  public let senderId: String
  public let senderLogin: String
  public let senderDisplayName: String

  public let badges: [ChatBadge]
  public let color: String

  @available(
    *, deprecated,
    message:
      "Not officially deprecated by twitch, but if possible check using `badges` instead."
  ) public let turbo: Bool

  internal init(from message: WHISPER) {
    self.rawIRCTags = message.rawIRCTags
    self.rawIRCMessage = message.rawIRCMessage

    self.message = message.message
    self.messageId = message.messageId
    self.emotes = message.emotes.components(separatedBy: "/").compactMap(
      ChatEmote.init)

    self.threadId = message.threadId

    self.senderId = message.userId
    self.senderLogin = message.senderLogin
    self.senderDisplayName = message.displayName

    self.badges = message.badges.components(separatedBy: ",").compactMap {
      ChatBadge(from: $0)
    }
    self.color = message.color

    self.turbo = message.turbo ?? false
  }
}
