import Testing

@testable import Twitch

struct CredentialsTests {
  let accessToken = "abcdefghijklmnop"
  let clientID = "1234567890"
  let userID = "1234"
  let userLogin = "user"

  @Test
  func initialization() {
    let credentials = TwitchCredentials(
      accessToken: accessToken, clientID: clientID, userID: userID, userLogin: userLogin)

    #expect(credentials.accessToken == accessToken)
    #expect(credentials.clientID == clientID)
    #expect(credentials.userID == userID)
    #expect(credentials.userLogin == userLogin)
  }

  @Test
  func withOAuthPrefix() {
    let credentials = TwitchCredentials(
      accessToken: "oauth:" + accessToken, clientID: clientID, userID: userID,
      userLogin: userLogin)

    #expect(credentials.accessToken == accessToken)
  }

  @Test
  func httpHeaders() {
    let credentials = TwitchCredentials(
      accessToken: accessToken, clientID: clientID, userID: userID, userLogin: userLogin)

    let headers = credentials.httpHeaders()

    #expect(headers["Authorization"] == "Bearer \(accessToken)")
    #expect(headers["Client-Id"] == clientID)
  }
}
