public struct Userstate {
  public var rawIRCTags: [String: String]
  public var rawIRCMessage: String

  public let channelName: String

  public let badges: [ChatBadge]
  public let color: String
  public let displayName: String
  public let emoteSets: [String]

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

  internal init(from message: USERSTATE) {
    self.rawIRCTags = message.rawIRCTags
    self.rawIRCMessage = message.rawIRCMessage

    self.channelName = message.channelName

    let badgeInfo = message.badgeInfo.components(separatedBy: ",")
    self.badges = message.badges.components(separatedBy: ",").compactMap {
      ChatBadge(from: $0, with: badgeInfo)
    }
    self.color = message.color
    self.displayName = message.displayName
    self.emoteSets = message.emoteSets.components(separatedBy: ",")

    self.subscriber = message.subscriber
    self.mod = message.mod
    self.turbo = message.turbo ?? false
  }
}
