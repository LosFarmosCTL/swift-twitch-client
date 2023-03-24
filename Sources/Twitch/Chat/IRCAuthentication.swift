public enum IRCAuthentication {
  case anonymous
  case authenticated(loginName: String, TwitchCredentials)
}
