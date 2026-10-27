import Testing

@testable import Twitch

struct IRCAuthenticationTests {
  @Test(arguments: [true, false], [TwitchIRCClient.Mode.receiveOnly, .readWrite])
  func appTokensRejectBothConstructionPathsBeforeConnecting(
    useFactory: Bool, mode: TwitchIRCClient.Mode
  ) async throws {
    let network = MockNetworkSession()
    let credentials = TwitchCredentials.app(
      accessToken: "app-token", clientID: "client-id")
    let twitch = TwitchClient(credentials: credentials, network: network)
    let irc: TwitchIRCClient
    if useFactory {
      irc = await twitch.makeIRCClient(mode: mode)
    } else {
      irc = TwitchIRCClient(.authenticated(credentials), mode: mode, network: network)
    }
    try await irc.setDesiredChannels(["channel"])
    await #expect(throws: TwitchAuthenticationError.userAccessTokenRequired) {
      try await irc.connect()
    }
    #expect(await network.taskCount() == 0)
    await irc.shutdown()
  }
}
