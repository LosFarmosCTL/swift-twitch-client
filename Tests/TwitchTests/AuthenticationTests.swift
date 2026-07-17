import Testing

@testable import Twitch

struct AuthenticationTests {
  let oAuth = "abcdefghijklmnop"
  let clientID = "1234567890"
  let userID = "1234"
  let userLogin = "user"

  @Test
  func initialization() {
    let auth = TwitchCredentials(
      oAuth: oAuth, clientID: clientID, userID: userID, userLogin: userLogin)

    #expect(auth.oAuth == oAuth)
    #expect(auth.clientID == clientID)
    #expect(auth.userID == userID)
    #expect(auth.userLogin == userLogin)
  }

  @Test
  func withOAuthPrefix() {
    let auth = TwitchCredentials(
      oAuth: "oauth:" + oAuth, clientID: clientID, userID: userID, userLogin: userLogin)

    #expect(auth.oAuth == oAuth)
  }

  @Test
  func httpHeaders() {
    let auth = TwitchCredentials(
      oAuth: oAuth, clientID: clientID, userID: userID, userLogin: userLogin)

    let headers = auth.httpHeaders()

    #expect(headers["Authorization"] == "Bearer \(oAuth)")
    #expect(headers["Client-Id"] == clientID)
  }
}
