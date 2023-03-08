public enum IRCAuthentication {
  case anonymous
  case authenticated(TwitchCredentials)
}
