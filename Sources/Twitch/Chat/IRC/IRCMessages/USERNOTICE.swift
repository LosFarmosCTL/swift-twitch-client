import Foundation

internal struct USERNOTICE: IRCMessage {
  let rawIRCTags: [String: String]
  let rawIRCMessage: String

  let msgId: String

  let message: String

  let channelName: String

  let badgeInfo: String
  let badges: String
  let color: String
  let displayName: String
  let emotes: String
  let flags: String
  let id: String
  let roomId: String
  let tmiSentTs: Date
  let userId: String
  let login: String

  let msgParams: [String: String]

  let systemMsg: String
}
