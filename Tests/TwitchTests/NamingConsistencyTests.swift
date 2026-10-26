import Foundation
import Testing

@testable import Twitch

struct NamingConsistencyTests {
  @Test
  func renamedDisplayNameDecodesOriginalWireKey() throws {
    let data = Data(
      """
      {"user_id":"1234","user_login":"viewer","user_name":"Viewer"}
      """.utf8)

    let chatter = try TwitchClient.makeDecoder().decode(Chatter.self, from: data)

    #expect(chatter.userID == "1234")
    #expect(chatter.userLogin == "viewer")
    #expect(chatter.userDisplayName == "Viewer")
  }

  @Test
  func renamedURLsDecodeOriginalWireKeys() throws {
    let decoder = TwitchClient.makeDecoder()
    let gameData = Data(
      """
      {"id":"1","name":"Game","box_art_url":"https://example.com/art","igdb_id":"2"}
      """.utf8)
    let viewData = Data(
      """
      {"viewer_url":"https://example.com/view","can_link_external_content":true}
      """.utf8)

    let game = try decoder.decode(Game.self, from: gameData)
    let view = try decoder.decode(Extension.ExtensionView.self, from: viewData)

    #expect(game.boxArtURL == "https://example.com/art")
    #expect(view.viewerURL == "https://example.com/view")
  }

  @Test
  func cancelledCasesPreserveTwitchRawValues() throws {
    let decoder = TwitchClient.makeDecoder()
    let status = try decoder.decode(
      ChannelPredictionEndEvent.Status.self,
      from: Data("\"canceled\"".utf8))
    let redemption = try decoder.decode(
      CustomRewardRedemptionStatus.self,
      from: Data("\"CANCELED\"".utf8))
    let encoded = try TwitchClient.makeEncoder().encode(redemption)

    #expect(status == .cancelled)
    #expect(redemption == .cancelled)
    #expect(String(data: encoded, encoding: .utf8) == "\"CANCELED\"")
  }

  @Test
  func helixAndEventSubShareSubscriptionTier() throws {
    let tier = try TwitchClient.makeDecoder().decode(
      SubscriptionTier.self, from: Data("\"1000\"".utf8))
    let notice = SubNotice(subscriptionTier: tier, isPrime: false, durationMonths: 1)

    #expect(notice.subscriptionTier == .tier1)
  }
}
