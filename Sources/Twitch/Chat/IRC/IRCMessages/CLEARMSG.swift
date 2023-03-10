import Foundation

internal struct CLEARMSG: IRCMessage {
  internal let rawIRCTags: [String: String]
  internal let rawIRCMessage: String

  internal let channelName: String

  internal let targetMsgId: String
  internal let targetLogin: String

  internal let tmiSentTs: Date

  @available(
    *, deprecated,
    message: "Seems to always be empty, check only using `targetMsgId` instead."
  ) internal let roomId: String
}
