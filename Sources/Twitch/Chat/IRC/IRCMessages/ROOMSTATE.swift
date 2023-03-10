public struct ROOMSTATE: IRCMessage {
  public let rawIRCTags: [String: String]
  public let rawIRCMessage: String

  public var channelId: String { return roomId }
  public let channelName: String

  internal let roomId: String

  public let emoteOnly: Bool
  public let followersOnly: Int?
  public let subsOnly: Bool
  public let r9k: Bool
  public let slow: Int?
  public let rituals: Bool
}
