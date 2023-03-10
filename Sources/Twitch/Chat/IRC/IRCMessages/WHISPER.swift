internal struct WHISPER: IRCMessage {
  internal let rawIRCTags: [String: String]
  internal let rawIRCMessage: String

  internal let message: String
  internal let senderLogin: String

  internal let badges: String
  internal let color: String
  internal let displayName: String
  internal let emotes: String
  internal let userId: String

  internal let messageId: String
  internal let threadId: String

  internal let turbo: Bool?
}
