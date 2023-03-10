internal struct USERSTATE: IRCMessage {
  internal let rawIRCTags: [String: String]
  internal let rawIRCMessage: String

  internal let channelName: String

  internal let badges: String
  internal let badgeInfo: String
  internal let color: String
  internal let displayName: String
  internal let emoteSets: String

  internal let mod: Bool?
  internal let subscriber: Bool?
  internal let turbo: Bool?
}
