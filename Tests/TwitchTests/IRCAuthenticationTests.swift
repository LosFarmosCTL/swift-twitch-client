import Testing

@testable import Twitch

@Suite(.timeLimit(.minutes(1)))
struct IRCAuthenticationTests {
  @Test(arguments: [true, false])
  func credentialsCannotInjectCommandsOrStartRecovery(inToken: Bool) async {
    let session = MockNetworkSession()
    let injected = "value\r\nJOIN #other"
    let client = TwitchClient(
      credentials: TwitchCredentials(
        accessToken: inToken ? injected : "token", clientID: "id", userID: "user",
        userLogin: inToken ? "tester" : injected),
      chat: .init(reader: .irc(.authenticated), writer: .irc), network: session)

    let error = await #expect(throws: IRCError.self) {
      try await client.sendIRC(.privateMessage(to: "swift", message: "hello"))
    }
    guard case .invalidInput(let parameter) = error else {
      Issue.record("Expected an IRC input-validation error")
      await client.shutdownChat()
      return
    }
    #expect(parameter == (inToken ? "accessToken" : "userLogin"))
    await #expect {
      try await client.join(to: ChatChannel(id: "123", login: "swift"))
    } throws: { error in
      switch error {
      case IRCError.invalidInput, ChatError.setupFailed: true
      default: false
      }
    }
    #expect(await session.taskCount() == 0)
    #expect(await client.chatState.ircWriter?.recoveries.isEmpty == true)
    await client.shutdownChat()
  }

  @Test
  func appTokensCannotStartAuthenticatedChatTransports() async {
    let session = MockNetworkSession()
    let client = TwitchClient(
      credentials: .app(accessToken: "app-token", clientID: "client-id"),
      chat: .init(reader: .irc(.authenticated), writer: .irc), network: session)

    await #expect(throws: ChatError.self) {
      try await client.join(to: ChatChannel(id: "123", login: "swift"))
    }
    await #expect(throws: TwitchAuthenticationError.userAccessTokenRequired) {
      try await client.sendIRC(.privateMessage(to: "swift", message: "hello"))
    }
    #expect(await session.taskCount() == 0)
    await client.shutdownChat()
  }
}
