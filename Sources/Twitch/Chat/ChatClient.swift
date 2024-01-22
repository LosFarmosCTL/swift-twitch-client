import TwitchIRC

public class ChatClient {
  private let authentication: IRCAuthentication

  private let client: TwitchIRCClient

  public init(_ authentication: IRCAuthentication) {
    self.authentication = authentication

    self.client = TwitchIRCClient(with: self.authentication)
  }

  // TODO: specify error type
  public func connect() async throws -> AsyncThrowingStream<
    IncomingMessage, Error
  > { return try await client.connect() }

  public func disconnect() { client.disconnect() }

  public func send(
    _ message: String, in channel: String, replyingTo messageId: String? = nil,
    nonce: String? = nil
  ) async throws {
    try await client.send(
      message, in: cleanChannelName(channel), replyingTo: messageId,
      nonce: nonce)
  }

  public func join(to channel: String) async throws {
    try await client.join(to: cleanChannelName(channel))
  }

  public func joinAll(channels: String...) async throws {
    for channel in channels { try await join(to: cleanChannelName(channel)) }
  }

  public func part(from channel: String) async throws {
    try await client.part(from: cleanChannelName(channel))
  }

  private func cleanChannelName(_ channel: String) -> String {
    return channel.lowercased().trimmingCharacters(in: ["#", " "])
  }
}
