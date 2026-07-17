@testable import Twitch

struct HelixTestHarness {
  let session: MockNetworkSession
  let twitch: TwitchClient

  init(
    authentication: TwitchCredentials = .init(
      oAuth: "1234567989",
      clientID: "abcdefghijkl",
      userID: "1234",
      userLogin: "user")
  ) {
    let session = MockNetworkSession()

    self.session = session
    self.twitch = TwitchClient(
      authentication: authentication,
      network: session)
  }
}
