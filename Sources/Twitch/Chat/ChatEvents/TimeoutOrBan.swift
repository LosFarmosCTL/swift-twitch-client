import Foundation

public struct TimeoutOrBan {
  public let rawIRCTags: [String: String]
  public let rawIRCMessage: String

  public let channelName: String
  public let channelId: String

  public let targetUserId: String
  public let targetLogin: String

  public let timestamp: Date

  public let duration: Int?

  internal init(from message: CLEARCHAT) {
    self.rawIRCTags = message.rawIRCTags
    self.rawIRCMessage = message.rawIRCMessage

    self.channelName = message.channelName
    self.channelId = message.roomId

    self.targetUserId = message.targetUserId
    self.targetLogin = message.targetLogin

    self.timestamp = message.tmiSentTs

    self.duration = message.banDuration
  }
}
