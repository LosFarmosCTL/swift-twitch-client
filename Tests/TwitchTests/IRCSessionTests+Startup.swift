import Foundation
import Testing

@testable import Twitch

extension IRCSessionTests {
  @Test(
    arguments: [TwitchIRCClient.Mode.receiveOnly, .readWrite], [false, true])
  func healthyReaderDeliversChatWhileAnotherReaderIsUnavailable(
    mode: TwitchIRCClient.Mode, retrying: Bool
  ) async throws {
    let client = TwitchIRCClient(.anonymous, mode: mode, network: session)
    try await client.setDesiredChannels((0..<91).map { "channel\($0)" })
    var messages = await client.messages().makeAsyncIterator()
    let pending = Task { try await client.connect() }
    defer { pending.cancel() }

    if mode == .readWrite {
      let writer = await session.waitForTask(at: 0)
      await handshake(writer)
    }

    let readIndex = if mode == .readWrite { 1 } else { 0 }
    let healthy = await session.waitForTask(at: readIndex)
    let unavailable = await session.waitForTask(at: readIndex + 1)
    await unavailable.waitForSent("NICK")
    await handshake(healthy)
    await healthy.waitForSent("JOIN")

    let channels = await healthy.sentMessages.compactMap { message -> String? in
      guard case .string(let text) = message else { return nil }
      guard text.hasPrefix("JOIN #") else { return nil }

      return String(text.dropFirst("JOIN #".count))
    }
    let channel = try #require(channels.first)

    if retrying {
      await unavailable.simulateError(URLError(.networkConnectionLost))
      _ = try #require(
        await client.stateUpdates().first {
          $0.recoveries.contains { $0.retryAt != nil }
        })
    }

    await healthy.simulateIncoming(
      .string(
        "@display-name=tester;user-id=123 "
          + ":tester!tester@tester.tmi.twitch.tv PRIVMSG #\(channel) :healthy chat"))
    let message = try #require(try await messages.next())

    if case .privateMessage(let chat) = message {
      #expect(chat.channel == channel)
      #expect(chat.message == "healthy chat")
    } else {
      Issue.record("Healthy reader did not deliver its chat during startup")
    }

    #expect(await client.state.status != .connected)
    #expect(await healthy.didCancel == false)

    await client.shutdown()
    await #expect(throws: IRCError.self) { try await pending.value }
    #expect(try await messages.next() == nil)
  }
}
