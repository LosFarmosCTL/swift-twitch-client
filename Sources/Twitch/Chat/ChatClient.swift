public class ChatClient {
  private let authentication: TwitchCredentials?
  private let client: IRCClient

  internal var listener: [ChatEvent] = []

  public init(_ authentication: IRCAuthentication) {
    switch authentication {
    case .anonymous: self.authentication = nil
    case .authenticated(let credentials): self.authentication = credentials
    }

    self.client = IRCClient()
    self.client.delegate = self
  }

  public func listen(on event: ChatEvent) { self.listener.append(event) }
}
