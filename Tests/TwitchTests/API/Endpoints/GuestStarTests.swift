import Foundation
import Testing

@testable import Twitch

struct GuestStarTests {
  private let harness = HelixTestHarness()

  @Test
  func getChannelGuestStarSettings() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/guest_star/channel_settings?broadcaster_id=1234&moderator_id=1234"
      ))

    await harness.session.stub(
      url: url,
      body: MockedData.getChannelGuestStarSettingsJSON)

    let settings = try await harness.twitch.helix(
      endpoint: .getChannelGuestStarSettings())

    #expect(settings.isModeratorSendLiveEnabled == true)
    #expect(settings.slotCount == 4)
    #expect(settings.isBrowserSourceAudioEnabled == true)
    #expect(settings.groupLayout == .tiledLayout)
    #expect(settings.browserSourceToken == "eihq8rew7q3hgierufhi3q")
  }

  @Test
  func updateChannelGuestStarSettings() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/guest_star/channel_settings?broadcaster_id=1234&is_moderator_send_live_enabled=false&slot_count=6&is_browser_source_audio_enabled=true&group_layout=HORIZONTAL_LAYOUT&regenerate_browser_sources=true"
      ))

    await harness.session.stub(
      url: url,
      method: "PUT",
      status: 204)

    try await harness.twitch.helix(
      endpoint: .updateChannelGuestStarSettings(
        isModeratorSendLiveEnabled: false,
        slotCount: 6,
        isBrowserSourceAudioEnabled: true,
        groupLayout: .horizontalLayout,
        regenerateBrowserSources: true))
  }

  @Test
  func getGuestStarSession() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/guest_star/session?broadcaster_id=1234&moderator_id=1234"
      ))

    await harness.session.stub(
      url: url,
      body: MockedData.getGuestStarSessionJSON)

    let session = try await harness.twitch.helix(endpoint: .getGuestStarSession())

    #expect(session.id == "2KFRQbFtpmfyD3IevNRnCzOPRJI")
    #expect(session.guests.count == 2)

    #expect(session.guests.first?.slotID == "0")
    #expect(session.guests.first?.userID == "9321049")
    #expect(session.guests.first?.userDisplayName == "Cool_User")
    #expect(session.guests.first?.userLogin == "cool_user")
    #expect(session.guests.first?.isLive == true)
    #expect(session.guests.first?.volume == 100)
    #expect(
      session.guests.first?.assignedAt.formatted(.iso8601) == "2023-01-02T04:16:53Z")
    #expect(session.guests.first?.audioSettings.isAvailable == true)
    #expect(session.guests.first?.videoSettings.isAvailable == true)
  }

  @Test
  func createGuestStarSession() async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/guest_star/session?broadcaster_id=1234"))

    await harness.session.stub(
      url: url,
      method: "POST",
      body: MockedData.createGuestStarSessionJSON)

    let session = try await harness.twitch.helix(endpoint: .createGuestStarSession())

    #expect(session.id == "2KFRQbFtpmfyD3IevNRnCzOPRJI")
    #expect(session.guests.count == 1)
    #expect(session.guests.first?.slotID == "0")
    #expect(session.guests.first?.userID == "9321049")
    #expect(session.guests.first?.isLive == true)
  }

  @Test
  func endGuestStarSession() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/guest_star/session?broadcaster_id=1234&session_id=2KFRQbFtpmfyD3IevNRnCzOPRJI"
      ))

    await harness.session.stub(
      url: url,
      method: "DELETE",
      body: MockedData.endGuestStarSessionJSON)

    let session = try await harness.twitch.helix(
      endpoint: .endGuestStarSession(sessionID: "2KFRQbFtpmfyD3IevNRnCzOPRJI"))

    #expect(session.id == "2KFRQbFtpmfyD3IevNRnCzOPRJI")
    #expect(session.guests.count == 1)
    #expect(session.guests.first?.slotID == "0")
    #expect(session.guests.first?.userLogin == "cool_user")
  }

  @Test
  func getGuestStarInvites() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/guest_star/invites?broadcaster_id=1234&moderator_id=1234&session_id=2KFRQbFtpmfyD3IevNRnCzOPRJI"
      ))

    await harness.session.stub(
      url: url,
      body: MockedData.getGuestStarInvitesJSON)

    let invites = try await harness.twitch.helix(
      endpoint: .getGuestStarInvites(sessionID: "2KFRQbFtpmfyD3IevNRnCzOPRJI"))

    #expect(invites.count == 1)
    #expect(invites.first?.userID == "144601104")
    #expect(invites.first?.status == .invited)
    #expect(invites.first?.isAudioEnabled == false)
    #expect(invites.first?.isVideoEnabled == true)
    #expect(invites.first?.isAudioAvailable == true)
    #expect(invites.first?.isVideoAvailable == true)
    #expect(invites.first?.invitedAt.formatted(.iso8601) == "2023-01-02T04:16:53Z")
  }

  @Test
  func sendGuestStarInvite() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/guest_star/invites?broadcaster_id=1234&moderator_id=1234&session_id=2KFRQbFtpmfyD3IevNRnCzOPRJI&guest_id=144601104"
      ))

    await harness.session.stub(
      url: url,
      method: "POST",
      status: 204)

    try await harness.twitch.helix(
      endpoint: .sendGuestStarInvite(
        sessionID: "2KFRQbFtpmfyD3IevNRnCzOPRJI",
        guestID: "144601104"))
  }

  @Test
  func deleteGuestStarInvite() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/guest_star/invites?broadcaster_id=1234&moderator_id=1234&session_id=2KFRQbFtpmfyD3IevNRnCzOPRJI&guest_id=144601104"
      ))

    await harness.session.stub(
      url: url,
      method: "DELETE",
      status: 204)

    try await harness.twitch.helix(
      endpoint: .deleteGuestStarInvite(
        sessionID: "2KFRQbFtpmfyD3IevNRnCzOPRJI",
        guestID: "144601104"))
  }

  @Test
  func assignGuestStarSlot() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/guest_star/slot?broadcaster_id=1234&moderator_id=1234&session_id=2KFRQbFtpmfyD3IevNRnCzOPRJI&guest_id=144601104&slot_id=1"
      ))

    await harness.session.stub(
      url: url,
      method: "POST",
      status: 204)

    try await harness.twitch.helix(
      endpoint: .assignGuestStarSlot(
        sessionID: "2KFRQbFtpmfyD3IevNRnCzOPRJI",
        guestID: "144601104",
        slotID: "1"))
  }

  @Test
  func updateGuestStarSlot() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/guest_star/slot?broadcaster_id=1234&moderator_id=1234&session_id=2KFRQbFtpmfyD3IevNRnCzOPRJI&source_slot_id=1&destination_slot_id=2"
      ))

    await harness.session.stub(
      url: url,
      method: "PATCH",
      status: 204)

    try await harness.twitch.helix(
      endpoint: .updateGuestStarSlot(
        sessionID: "2KFRQbFtpmfyD3IevNRnCzOPRJI",
        sourceSlotID: "1",
        destinationSlotID: "2"))
  }

  @Test
  func deleteGuestStarSlot() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/guest_star/slot?broadcaster_id=1234&moderator_id=1234&session_id=2KFRQbFtpmfyD3IevNRnCzOPRJI&guest_id=144601104&slot_id=1&should_reinvite_guest=true"
      ))

    await harness.session.stub(
      url: url,
      method: "DELETE",
      status: 204)

    try await harness.twitch.helix(
      endpoint: .deleteGuestStarSlot(
        sessionID: "2KFRQbFtpmfyD3IevNRnCzOPRJI",
        guestID: "144601104",
        slotID: "1",
        shouldReinviteGuest: true))
  }

  @Test
  func updateGuestStarSlotSettings() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/guest_star/slot_settings?broadcaster_id=1234&moderator_id=1234&session_id=2KFRQbFtpmfyD3IevNRnCzOPRJI&slot_id=1&is_audio_enabled=false&is_video_enabled=true&is_live=true&volume=40"
      ))

    await harness.session.stub(
      url: url,
      method: "PATCH",
      status: 204)

    try await harness.twitch.helix(
      endpoint: .updateGuestStarSlotSettings(
        sessionID: "2KFRQbFtpmfyD3IevNRnCzOPRJI",
        slotID: "1",
        isAudioEnabled: false,
        isVideoEnabled: true,
        isLive: true,
        volume: 40))
  }
}
