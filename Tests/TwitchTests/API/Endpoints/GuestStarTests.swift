import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class GuestStarTests: XCTestCase {
  private var twitch: TwitchClient!

  override func setUpWithError() throws {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockingURLProtocol.self]
    let urlSession = URLSession(configuration: configuration)

    twitch = TwitchClient(
      authentication: .init(
        oAuth: "1234567989", clientID: "abcdefghijkl", userID: "1234", userLogin: "user"),
      urlSession: urlSession)
  }

  func testGetChannelGuestStarSettings() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/guest_star/channel_settings?broadcaster_id=1234&moderator_id=1234"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getChannelGuestStarSettingsJSON]
    ).register()

    let settings = try await twitch.helix(endpoint: .getChannelGuestStarSettings())

    XCTAssertEqual(settings.isModeratorSendLiveEnabled, true)
    XCTAssertEqual(settings.slotCount, 4)
    XCTAssertEqual(settings.isBrowserSourceAudioEnabled, true)
    XCTAssertEqual(settings.groupLayout, .tiledLayout)
    XCTAssertEqual(settings.browserSourceToken, "eihq8rew7q3hgierufhi3q")
  }

  func testUpdateChannelGuestStarSettings() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/guest_star/channel_settings?broadcaster_id=1234&is_moderator_send_live_enabled=false&slot_count=6&is_browser_source_audio_enabled=true&group_layout=HORIZONTAL_LAYOUT&regenerate_browser_sources=true"
    )!

    var request = URLRequest(url: url)
    request.httpMethod = "PUT"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.helix(
      endpoint: .updateChannelGuestStarSettings(
        isModeratorSendLiveEnabled: false,
        slotCount: 6,
        isBrowserSourceAudioEnabled: true,
        groupLayout: .horizontalLayout,
        regenerateBrowserSources: true))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }

  func testGetGuestStarSession() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/guest_star/session?broadcaster_id=1234&moderator_id=1234"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getGuestStarSessionJSON]
    ).register()

    let session = try await twitch.helix(endpoint: .getGuestStarSession())

    XCTAssertEqual(session.id, "2KFRQbFtpmfyD3IevNRnCzOPRJI")
    XCTAssertEqual(session.guests.count, 2)

    XCTAssertEqual(session.guests.first?.slotID, "0")
    XCTAssertEqual(session.guests.first?.userID, "9321049")
    XCTAssertEqual(session.guests.first?.userDisplayName, "Cool_User")
    XCTAssertEqual(session.guests.first?.userLogin, "cool_user")
    XCTAssertEqual(session.guests.first?.isLive, true)
    XCTAssertEqual(session.guests.first?.volume, 100)
    XCTAssertEqual(
      session.guests.first?.assignedAt.formatted(.iso8601), "2023-01-02T04:16:53Z")
    XCTAssertEqual(session.guests.first?.audioSettings.isAvailable, true)
    XCTAssertEqual(session.guests.first?.videoSettings.isAvailable, true)
  }

  func testCreateGuestStarSession() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/guest_star/session?broadcaster_id=1234")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.post: MockedData.createGuestStarSessionJSON]
    ).register()

    let session = try await twitch.helix(endpoint: .createGuestStarSession())

    XCTAssertEqual(session.id, "2KFRQbFtpmfyD3IevNRnCzOPRJI")
    XCTAssertEqual(session.guests.count, 1)
    XCTAssertEqual(session.guests.first?.slotID, "0")
    XCTAssertEqual(session.guests.first?.userID, "9321049")
    XCTAssertEqual(session.guests.first?.isLive, true)
  }

  func testEndGuestStarSession() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/guest_star/session?broadcaster_id=1234&session_id=2KFRQbFtpmfyD3IevNRnCzOPRJI"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.delete: MockedData.endGuestStarSessionJSON]
    ).register()

    let session = try await twitch.helix(
      endpoint: .endGuestStarSession(sessionID: "2KFRQbFtpmfyD3IevNRnCzOPRJI"))

    XCTAssertEqual(session.id, "2KFRQbFtpmfyD3IevNRnCzOPRJI")
    XCTAssertEqual(session.guests.count, 1)
    XCTAssertEqual(session.guests.first?.slotID, "0")
    XCTAssertEqual(session.guests.first?.userLogin, "cool_user")
  }

  func testGetGuestStarInvites() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/guest_star/invites?broadcaster_id=1234&moderator_id=1234&session_id=2KFRQbFtpmfyD3IevNRnCzOPRJI"
    )!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getGuestStarInvitesJSON]
    ).register()

    let invites = try await twitch.helix(
      endpoint: .getGuestStarInvites(sessionID: "2KFRQbFtpmfyD3IevNRnCzOPRJI"))

    XCTAssertEqual(invites.count, 1)
    XCTAssertEqual(invites.first?.userID, "144601104")
    XCTAssertEqual(invites.first?.status, .invited)
    XCTAssertEqual(invites.first?.isAudioEnabled, false)
    XCTAssertEqual(invites.first?.isVideoEnabled, true)
    XCTAssertEqual(invites.first?.isAudioAvailable, true)
    XCTAssertEqual(invites.first?.isVideoAvailable, true)
    XCTAssertEqual(
      invites.first?.invitedAt.formatted(.iso8601), "2023-01-02T04:16:53Z")
  }

  func testSendGuestStarInvite() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/guest_star/invites?broadcaster_id=1234&moderator_id=1234&session_id=2KFRQbFtpmfyD3IevNRnCzOPRJI&guest_id=144601104"
    )!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.helix(
      endpoint: .sendGuestStarInvite(
        sessionID: "2KFRQbFtpmfyD3IevNRnCzOPRJI",
        guestID: "144601104"))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }

  func testDeleteGuestStarInvite() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/guest_star/invites?broadcaster_id=1234&moderator_id=1234&session_id=2KFRQbFtpmfyD3IevNRnCzOPRJI&guest_id=144601104"
    )!

    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.helix(
      endpoint: .deleteGuestStarInvite(
        sessionID: "2KFRQbFtpmfyD3IevNRnCzOPRJI",
        guestID: "144601104"))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }

  func testAssignGuestStarSlot() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/guest_star/slot?broadcaster_id=1234&moderator_id=1234&session_id=2KFRQbFtpmfyD3IevNRnCzOPRJI&guest_id=144601104&slot_id=1"
    )!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.helix(
      endpoint: .assignGuestStarSlot(
        sessionID: "2KFRQbFtpmfyD3IevNRnCzOPRJI",
        guestID: "144601104",
        slotID: "1"))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }

  func testUpdateGuestStarSlot() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/guest_star/slot?broadcaster_id=1234&moderator_id=1234&session_id=2KFRQbFtpmfyD3IevNRnCzOPRJI&source_slot_id=1&destination_slot_id=2"
    )!

    var request = URLRequest(url: url)
    request.httpMethod = "PATCH"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.helix(
      endpoint: .updateGuestStarSlot(
        sessionID: "2KFRQbFtpmfyD3IevNRnCzOPRJI",
        sourceSlotID: "1",
        destinationSlotID: "2"))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }

  func testDeleteGuestStarSlot() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/guest_star/slot?broadcaster_id=1234&moderator_id=1234&session_id=2KFRQbFtpmfyD3IevNRnCzOPRJI&guest_id=144601104&slot_id=1&should_reinvite_guest=true"
    )!

    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.helix(
      endpoint: .deleteGuestStarSlot(
        sessionID: "2KFRQbFtpmfyD3IevNRnCzOPRJI",
        guestID: "144601104",
        slotID: "1",
        shouldReinviteGuest: true))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }

  func testUpdateGuestStarSlotSettings() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/guest_star/slot_settings?broadcaster_id=1234&moderator_id=1234&session_id=2KFRQbFtpmfyD3IevNRnCzOPRJI&slot_id=1&is_audio_enabled=false&is_video_enabled=true&is_live=true&volume=40"
    )!

    var request = URLRequest(url: url)
    request.httpMethod = "PATCH"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.helix(
      endpoint: .updateGuestStarSlotSettings(
        sessionID: "2KFRQbFtpmfyD3IevNRnCzOPRJI",
        slotID: "1",
        isAudioEnabled: false,
        isVideoEnabled: true,
        isLive: true,
        volume: 40))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }
}
