import Foundation

public struct DeletedMessage {
  public var rawIRCTags: [String: String]
  public var rawIRCMessage: String

  public let channelName: String

  public let targetLogin: String
  public let targetMessageId: String

  public let timestamp: Date

  internal init(from message: CLEARMSG) {
    self.rawIRCTags = message.rawIRCTags
    self.rawIRCMessage = message.rawIRCMessage

    self.channelName = message.channelName

    self.targetLogin = message.targetLogin
    self.targetMessageId = message.targetMsgId

    self.timestamp = message.tmiSentTs
  }
}
