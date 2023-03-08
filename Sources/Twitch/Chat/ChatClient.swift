public class ChatClient: IRCClientDelegate {
  private let authentication: TwitchCredentials?
  private let client: IRCClient

  public init(_ authentication: IRCAuthentication) {
    switch authentication {
    case .anonymous: self.authentication = nil
    case .authenticated(let credentials): self.authentication = credentials
    }

    self.client = IRCClient()
    self.client.delegate = self
  }

  func didReceiveMessage(_ message: IRCMessage) { print(message) }
}
