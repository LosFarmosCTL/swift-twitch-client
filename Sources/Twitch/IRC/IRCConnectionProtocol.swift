import Foundation
import TwitchIRC

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public protocol IRCConnectionProtocol: Actor {
  var joinedChannels: Set<String> { get }

  init(credentials: TwitchCredentials?, urlSession: URLSession)

  @discardableResult
  func connect() async throws -> AsyncThrowingStream<IncomingMessage, Error>
  func disconnect() async throws
  func send(_ message: OutgoingMessage) async throws
  func join(to channel: String) async throws
  func part(from channel: String) async throws
}

extension IRCConnectionProtocol {
  public typealias Factory = (TwitchCredentials?, URLSession) -> Self
}
