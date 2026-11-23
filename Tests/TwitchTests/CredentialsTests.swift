import Testing

@testable import Twitch

struct CredentialsTests {
  @Test
  func appCredentialsNormalizeTokenAndOmitUserIdentity() {
    let credentials = TwitchCredentials.app(
      accessToken: "oauth:app-token", clientID: "1234567890")
    #expect(credentials.kind == .app)
    #expect(credentials.user == nil)
    #expect(credentials.userID == nil)
    #expect(credentials.userLogin == nil)
    #expect(credentials.accessToken == "app-token")
    #expect(credentials.httpHeaders() == [
      "Authorization": "Bearer app-token",
      "Client-Id": "1234567890",
    ])
  }

  @Test
  func userCredentialsNormalizeTokenAndLogin() {
    let credentials = TwitchCredentials(
      accessToken: "oauth:abcdefghijklmnop", clientID: "1234567890",
      userID: "1234", userLogin: "Some_User")
    #expect(credentials.accessToken == "abcdefghijklmnop")
    #expect(credentials.kind == .user(.init(id: "1234", login: "some_user")))
    #expect(credentials.user?.login == "some_user")
    #expect(credentials.httpHeaders() == [
      "Authorization": "Bearer abcdefghijklmnop",
      "Client-Id": "1234567890",
    ])
  }
}
