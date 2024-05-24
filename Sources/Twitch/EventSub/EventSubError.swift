public enum EventSubError: Error {
  case revocation(EventSubRevocation)
  case invalidWelcomeMessage
  case disconnected(with: Error, socketID: String)
}
