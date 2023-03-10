internal protocol IRCMessage {
  var rawIRCTags: [String: String] { get }
  var rawIRCMessage: String { get }
}
