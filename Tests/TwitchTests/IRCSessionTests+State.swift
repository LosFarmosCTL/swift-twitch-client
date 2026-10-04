import Foundation
import Testing

@testable import Twitch

extension IRCSessionTests {
  @Test
  func releasingClientClosesConnectionsAndFinishesObservers() async throws {
    func makeConnectedClient() async throws -> TwitchIRCClient {
      let client = TwitchIRCClient(.anonymous, network: session)
      let pending = Task { try await client.connect() }
      let writer = await session.waitForTask(at: 0)
      await handshake(writer)
      let reader = await session.waitForTask(at: 1)
      await handshake(reader)
      try await pending.value
      return client
    }

    var client: TwitchIRCClient? = try await makeConnectedClient()
    let states = try #require(await client?.stateUpdates())
    let messages = try #require(await client?.messages())
    let writer = try #require(await session.task(at: 0))
    let reader = try #require(await session.task(at: 1))

    client = nil
    await writer.waitForCancellation()
    await reader.waitForCancellation()

    for await _ in states {}
    var iterator = messages.makeAsyncIterator()
    #expect(try await iterator.next() == nil)
  }

  @Test
  func writerAuthenticationFailureWhileReaderConnectsPreservesTerminalError() async throws
  {
    let client = TwitchIRCClient(.anonymous, network: session)
    try await client.setDesiredChannels(["swift"])

    let pending = Task { try await client.connect() }
    let writer = await session.waitForTask(at: 0)
    await handshake(writer)

    let reader = await session.waitForTask(at: 1)
    await reader.waitForSent("NICK")

    await writer.simulateIncoming(
      .string(":tmi.twitch.tv NOTICE * :Login authentication failed"))

    let error = await #expect(throws: IRCError.self) { try await pending.value }

    if case .loginFailed = error {
    } else {
      Issue.record("Authentication failure was masked")
    }

    #expect(await client.state.status == .failed(.authenticationFailed))

    await reader.waitForCancellation()
    #expect(await reader.didCancel)
  }
}
