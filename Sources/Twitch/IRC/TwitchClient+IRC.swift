import Foundation
import TwitchIRC

#if canImport(Combine)
  import Combine
#endif

extension TwitchClient {
  public func ircClient(_ authenticationStyle: IRCAuthenticationStyle) async throws
    -> TwitchIRCClient
  {
    let credentials: TwitchCredentials? = {
      switch authenticationStyle {
      case .authenticated: self.authentication
      case .anonymous: nil
      }
    }()

    return try await TwitchIRCClient(with: credentials, urlSession: self.urlSession)
  }
}

public enum IRCAuthenticationStyle {
  case anonymous, authenticated
}
