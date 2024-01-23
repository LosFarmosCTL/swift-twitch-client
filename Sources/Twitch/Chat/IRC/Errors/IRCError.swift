public enum IRCError: Error {
  case loginFailed
  case channelSuspended(_ channel: String)
  case bannedFromChannel(_ channel: String)
  case timedOut
}
