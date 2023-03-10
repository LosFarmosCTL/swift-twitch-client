import Foundation

internal struct PRIVMSG: IRCMessage {
  internal let rawIRCTags: [String: String]
  internal let rawIRCMessage: String

  internal let message: String
  internal let senderLogin: String
  internal let channelName: String

  internal let badges: String
  internal let badgeInfo: String
  internal let color: String
  internal let displayName: String
  internal let emotes: String
  internal let flags: String
  internal let id: String
  internal let roomId: String
  internal let tmiSentTs: Date
  internal let userId: String
  internal let firstMsg: Bool?

  internal let clientNonce: String?
  internal let replyParentDisplayName: String?
  internal let replyParentMsgBody: String?
  internal let replyParentMsgId: String?
  internal let replyParentUserId: String?
  internal let replyParentUserLogin: String?

  internal let turbo: Bool?
  internal let subscriber: Bool?
  internal let mod: Bool?
}
