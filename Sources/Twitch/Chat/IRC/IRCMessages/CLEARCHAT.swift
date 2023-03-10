import Foundation

internal struct CLEARCHAT: IRCMessage {
  internal let rawIRCTags: [String: String]
  internal let rawIRCMessage: String

  internal let channelName: String
  internal let roomId: String

  internal let banDuration: Int?

  internal let targetUserId: String
  internal let targetLogin: String

  internal let tmiSentTs: Date
}
