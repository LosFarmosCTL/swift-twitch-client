import Foundation
import Testing

@testable import Twitch

struct CredentialReconciliationTests {
  private let jwt = TwitchCredentials.extensionJWT(
    token: "signed.jwt.token", clientID: "extension")

  @Test
  func explicitJWTUsesBearerHeadersWithoutAnOAuthUser() async throws {
    #expect(jwt.kind == .extensionJWT)
    #expect(jwt.user == nil)
    let harness = HelixTestHarness(credentials: jwt)
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/extensions?extension_id=extension"))
    await harness.session.stub(url: url, body: MockedData.getExtensionJSON)
    let result = try await harness.twitch.helix(
      for: .getExtension(extensionID: "extension"))
    #expect(result.name == "Official Developers Demo")
    let request = try #require(await harness.session.lastRequest())
    #expect(
      request.value(forHTTPHeaderField: "Authorization") == "Bearer signed.jwt.token")
    #expect(request.value(forHTTPHeaderField: "Client-Id") == "extension")
  }

  @Test(arguments: [
    TwitchCredentials.Kind.user(.init(id: "bot", login: "bot")), .app,
  ])
  func oauthTokensCannotAuthorizeJWTOperations(kind: TwitchCredentials.Kind) async {
    let harness = HelixTestHarness(
      credentials: .init(accessToken: "oauth", clientID: "app", kind: kind))
    let error = await #expect(throws: HelixError.self) {
      try await harness.twitch.helix(
        for: .setExtensionRequiredConfiguration(
          for: "channel", extensionID: "extension", extensionVersion: "1",
          requiredConfiguration: "version"))
    }
    guard case .authenticationError(.extensionJWTRequired) = error else {
      Issue.record("Expected an Extension JWT requirement")
      return
    }
    #expect(await harness.session.requestCount() == 0)
  }

  @Test
  func jwtCannotAuthorizeOAuthOrAccountSessions() async {
    let harness = HelixTestHarness(credentials: jwt)
    let error = await #expect(throws: HelixError.self) {
      _ = try await harness.twitch.helix(for: .getUsers(userIDs: ["bot"]))
    }
    guard case .authenticationError(.oauthAccessTokenRequired) = error else {
      Issue.record("Expected OAuth credentials to be required")
      return
    }
    await #expect(throws: TwitchAuthenticationError.userAccessTokenRequired) {
      _ = try await harness.twitch.eventStream(
        for: .streamOnline(broadcasterID: "channel"))
    }
    let irc = await harness.twitch.makeIRCClient()
    await #expect(throws: TwitchAuthenticationError.userAccessTokenRequired) {
      try await irc.connect()
    }
    await irc.shutdown()
    #expect(await harness.session.requestCount() == 0)
    #expect(await harness.session.taskCount() == 0)
  }

  @Test(arguments: [
    TwitchCredentials.Kind.user(.init(id: "bot", login: "bot")), .app,
  ])
  func pinnedMessageRetainsPinAndExplicitSender(kind: TwitchCredentials.Kind) async throws
  {
    let harness = HelixTestHarness(
      credentials: .init(accessToken: "token", clientID: "app", kind: kind))
    let url = try #require(URL(string: "https://api.twitch.tv/helix/chat/messages"))
    await harness.session.stub(
      url: url, method: "POST", body: MockedData.sendChatMessageJSON)
    _ = try await harness.twitch.helix(
      for: .sendChatMessage(
        in: "channel", message: "hello", pin: true, senderID: "bot"))
    let data = try #require(await harness.session.lastRequest()?.httpBody)
    let body = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    #expect(body["pin"] as? Bool == true)
    #expect(body["sender_id"] as? String == "bot")
  }

  @Test
  func appAnnouncementRetainsSourceOnlyAndExplicitModerator() async throws {
    let harness = HelixTestHarness(
      credentials: .app(accessToken: "app", clientID: "client"))
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/chat/announcements?broadcaster_id=channel&moderator_id=bot"
      ))
    await harness.session.stub(url: url, method: "POST", status: 204)
    try await harness.twitch.helix(
      for: .sendAnnouncement(
        in: "channel", message: "hello", isSourceOnly: true, moderatorID: "bot"))
    let data = try #require(await harness.session.lastRequest()?.httpBody)
    let body = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    #expect(body["for_source_only"] as? Bool == true)
  }

  @Test(arguments: [true, false])
  func pinCannotBeCombinedWithReplyOrSourceOnly(useReply: Bool) async {
    let harness = HelixTestHarness(
      credentials: .app(accessToken: "app", clientID: "client"))
    let error = await #expect(throws: HelixError.self) {
      _ = try await harness.twitch.helix(
        for: .sendChatMessage(
          in: "channel", message: "hello", replyTo: useReply ? "parent" : nil,
          isSourceOnly: useReply ? nil : true, pin: true, senderID: "bot"))
    }
    guard
      case .authenticationError(.invalidParameter(parameter: "pin", reason: _)) = error
    else {
      Issue.record("Expected an incompatible pin parameter")
      return
    }
    #expect(await harness.session.requestCount() == 0)
  }
}
