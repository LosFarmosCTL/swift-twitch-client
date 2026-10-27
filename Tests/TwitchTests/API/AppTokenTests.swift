import Foundation
import Testing

@testable import Twitch

struct AppTokenTests {
  private let app = TwitchCredentials.app(accessToken: "app-token", clientID: "client-id")
  private let user = TwitchCredentials(
    accessToken: "user-token", clientID: "client-id", userID: "1234", userLogin: "user")

  @Test
  func normalVoidRawAndCallbackRequestsUseAppCredentials() async throws {
    let harness = HelixTestHarness(credentials: app)
    let streamsURL = try #require(URL(string: "https://api.twitch.tv/helix/streams"))
    await harness.session.stub(url: streamsURL, body: Data("{\"data\":[]}".utf8))
    let streams = try await harness.twitch.helix(for: .getStreams())
    #expect(streams.streams.isEmpty)

    let deletedURL = try #require(
      URL(string: "https://api.twitch.tv/helix/eventsub/conduits?id=conduit"))
    await harness.session.stub(url: deletedURL, method: "DELETE", status: 204)
    try await harness.twitch.helix(for: .deleteConduit(conduitID: "conduit"))

    let calendarURL = try #require(
      URL(string: "https://api.twitch.tv/helix/schedule/icalendar?broadcaster_id=1234"))
    await harness.session.stub(url: calendarURL, body: Data("BEGIN:VCALENDAR".utf8))
    let calendar = try await harness.twitch.helix(
      for: .getChannelICalendar(broadcasterID: "1234"))
    #expect(calendar == "BEGIN:VCALENDAR")

    try await confirmation { completed in
      let result = await withCheckedContinuation { continuation in
        _ = harness.twitch.helixTask(for: .getStreams()) { result in
          completed()
          continuation.resume(returning: result)
        }
      }
      let response = try result.get()
      #expect(response.streams.isEmpty)
    }
    for request in await harness.session.requests() {
      #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer app-token")
      #expect(request.value(forHTTPHeaderField: "Client-Id") == "client-id")
    }
  }

  @Test
  func endpointKindFailuresAreTypedBeforeNetworking() async {
    let appHarness = HelixTestHarness(credentials: app)
    let userHarness = HelixTestHarness(credentials: user)
    let appError = await #expect(throws: HelixError.self) {
      _ = try await appHarness.twitch.helix(for: .getFollowedStreams())
    }
    let userError = await #expect(throws: HelixError.self) {
      _ = try await userHarness.twitch.helix(for: .getConduits())
    }
    guard case .authenticationError(.userAccessTokenRequired) = appError,
      case .authenticationError(.appAccessTokenRequired) = userError
    else {
      Issue.record("Unexpected token kind errors")
      return
    }
    #expect(await appHarness.session.requestCount() == 0)
    #expect(await userHarness.session.requestCount() == 0)
  }

  @Test
  func staticAndCallbackEntryPointsPreserveAuthenticationErrors() async {
    let error = await #expect(throws: HelixError.self) {
      _ = try await TwitchClient.helix(for: .getStreamKey(), credentials: app)
    }
    guard case .authenticationError(.userAccessTokenRequired) = error else {
      Issue.record("Expected a user-token requirement")
      return
    }
    let result = await withCheckedContinuation { continuation in
      _ = TwitchClient.helixTask(for: .getStreamKey(), credentials: app) { result in
        continuation.resume(returning: result)
      }
    }
    guard case .failure(.authenticationError(.userAccessTokenRequired)) = result else {
      Issue.record("The callback did not preserve the authentication error")
      return
    }
  }

  @Test
  func appUserLookupRequiresTargetAndPreservesIdentityErrors() async throws {
    let harness = HelixTestHarness(credentials: app)
    let error = await #expect(throws: HelixError.self) {
      _ = try await harness.twitch.helix(for: .getUsers())
    }
    guard case .authenticationError(.missingUserID(parameter: "id or login")) = error
    else {
      Issue.record("Expected a missing lookup target")
      return
    }
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/users?login=twitchdev"))
    await harness.session.stub(url: url, body: Data("{\"data\":[]}".utf8))
    let users = try await harness.twitch.helix(for: .getUsers(userLogins: ["twitchdev"]))
    #expect(users.isEmpty)
  }

  @Test
  func chatSourceOnlyAndDropsFilterAreTokenDependent() async throws {
    let userHarness = HelixTestHarness(credentials: user)
    let sourceError = await #expect(throws: HelixError.self) {
      _ = try await userHarness.twitch.helix(
        for: .sendChatMessage(in: "channel", message: "hello", isSourceOnly: false))
    }
    let dropsError = await #expect(throws: HelixError.self) {
      _ = try await userHarness.twitch.helix(for: .getDropsEntitlements(userID: "target"))
    }
    guard
      case .authenticationError(
        .invalidParameter(parameter: "for_source_only", reason: _)) = sourceError,
      case .authenticationError(.invalidParameter(parameter: "user_id", reason: _)) =
        dropsError
    else {
      Issue.record("Expected token-dependent parameter errors")
      return
    }
    #expect(await userHarness.session.requestCount() == 0)

    let harness = HelixTestHarness(credentials: app)
    let url = try #require(URL(string: "https://api.twitch.tv/helix/chat/messages"))
    await harness.session.stub(
      url: url, method: "POST",
      body: Data("{\"data\":[{\"message_id\":\"sent\",\"is_sent\":true}]}".utf8))
    let sent = try await harness.twitch.helix(
      for: .sendChatMessage(
        in: "channel", message: "hello", isSourceOnly: true, senderID: "bot"))
    #expect(sent.isSent)
    let body = try #require(await harness.session.lastRequest()?.httpBody)
    let payload = try #require(JSONSerialization.jsonObject(with: body) as? [String: Any])
    #expect(payload["sender_id"] as? String == "bot")
    #expect(payload["for_source_only"] as? Bool == true)
  }

  @Test
  func autoModUsesTopLevelActorFields() async throws {
    let harness = HelixTestHarness(credentials: app)
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/moderation/automod/message"))
    await harness.session.stub(url: url, method: "POST", status: 204)
    try await harness.twitch.helix(
      for: .approveAutoModMessage(messageID: "held", userID: "moderator"))
    let body = try #require(await harness.session.lastRequest()?.httpBody)
    let payload = try JSONDecoder().decode([String: String].self, from: body)
    #expect(payload == ["user_id": "moderator", "msg_id": "held", "action": "ALLOW"])
  }

  @Test
  func twitchStillChecksAppPriorGrants() async throws {
    let harness = HelixTestHarness(credentials: app)
    let url = try #require(URL(string: "https://api.twitch.tv/helix/chat/messages"))
    await harness.session.stub(
      url: url, method: "POST", status: 401,
      body: Data(
        "{\"error\":\"Unauthorized\",\"status\":401,\"message\":\"Missing prior grant\"}"
          .utf8))
    let error = await #expect(throws: HelixError.self) {
      _ = try await harness.twitch.helix(
        for: .sendChatMessage(in: "channel", message: "hello", senderID: "bot"))
    }
    guard
      case .twitchError(
        name: "Unauthorized", status: 401, message: "Missing prior grant") = error
    else {
      Issue.record("Expected Twitch's authorization error")
      return
    }
    #expect(await harness.session.requestCount() == 1)
  }
}
