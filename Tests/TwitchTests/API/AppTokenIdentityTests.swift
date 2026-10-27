import Foundation
import Testing

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

struct AppTokenIdentityTests {
  private let app = TwitchCredentials.app(accessToken: "app", clientID: "client")
  private let user = TwitchCredentials(
    accessToken: "user", clientID: "client", userID: "actor", userLogin: "login")

  @Test(arguments: IdentityOperation.allCases)
  func explicitAppActorAndExistingUserDefault(operation: IdentityOperation) throws {
    let appRequest = try operation.request(credentials: app, actorID: "actor")
    let userRequest = try operation.request(credentials: user, actorID: nil)
    #expect(appRequest.url == userRequest.url)
    if let appBody = appRequest.httpBody, let userBody = userRequest.httpBody {
      let appJSON = try #require(
        JSONSerialization.jsonObject(with: appBody) as? NSDictionary)
      let userJSON = try #require(
        JSONSerialization.jsonObject(with: userBody) as? NSDictionary)
      #expect(appJSON == userJSON)
    } else {
      #expect(appRequest.httpBody == nil)
      #expect(userRequest.httpBody == nil)
    }
    #expect(appRequest.value(forHTTPHeaderField: "Authorization") == "Bearer app")
    #expect(userRequest.value(forHTTPHeaderField: "Authorization") == "Bearer user")
  }

  @Test(arguments: IdentityOperation.allCases, [nil, ""] as [String?])
  func appActorCannotBeOmitted(operation: IdentityOperation, actorID: String?) {
    let error = #expect(throws: TwitchAuthenticationError.self) {
      try operation.request(credentials: app, actorID: actorID)
    }
    guard case .missingUserID = error else {
      Issue.record("Expected a missing actor ID, got \(String(describing: error))")
      return
    }
  }

  @Test
  func userActorMustMatchTokenButLookupTargetCanDiffer() throws {
    #expect(throws: TwitchAuthenticationError.userIDMismatch(parameter: "sender_id")) {
      try IdentityOperation.chatMessage.request(credentials: user, actorID: "other")
    }
    let request = try IdentityOperation.channelTeams.request(
      credentials: user, actorID: "other")
    #expect(request.url?.query()?.contains("broadcaster_id=other") == true)
  }

  @Test
  func chatSettingsVariadicOverloadForwardsModerator() throws {
    let endpoint:
      HelixEndpoint<ChatSettings, ChatSettings, HelixEndpointResponseTypes.Normal> =
        .updateChatSettings(of: "channel", moderatorID: "actor", settings: .emoteMode)
    let request = try endpoint.makeRequest(
      using: app, encoder: TwitchClient.makeEncoder())
    #expect(request.url?.query()?.contains("moderator_id=actor") == true)
  }

  @Test
  func autoModVariadicOverloadForwardsBroadcaster() throws {
    let endpoint:
      HelixEndpoint<[AutoModStatus], AutoModStatus, HelixEndpointResponseTypes.Normal> =
        .checkAutoModStatus(
          messages: (id: "message", message: "text"), broadcasterID: "actor")
    let request = try endpoint.makeRequest(
      using: app, encoder: TwitchClient.makeEncoder())
    #expect(request.url?.query()?.contains("broadcaster_id=actor") == true)
  }
}

// Each case exercises a public factory that previously derived an actor from user credentials.
enum IdentityOperation: CaseIterable, Sendable {
  case adSchedule, snoozeAd, commercial
  case chatters, announcement, chatMessage, shoutout, chatSettings
  case addTerm, ban, checkAutoMod, deleteMessage, autoModSettings, bannedUsers,
    blockedTerms
  case moderatedChannels, shieldStatus, approveMessage, denyMessage, removeTerm, unban
  case updateAutoMod, updateShield, subscribers, channelTeams, activeExtensions

  case pinnedMessage, pinMessage, updatePin, unpinMessage, vodClip, clipDownloads
  case addSuspicious, removeSuspicious, warnUser

  func request(credentials: TwitchCredentials, actorID: String?) throws -> URLRequest {
    let make = try #require(Self.requests[self])
    return try make(credentials, actorID)
  }

  private static let requests:
    [Self: @Sendable (TwitchCredentials, String?) throws -> URLRequest] = [
      .adSchedule: { credentials, actorID in
        try makeIdentityRequest(.getAdSchedule(broadcasterID: actorID), credentials)
      },
      .snoozeAd: { credentials, actorID in
        try makeIdentityRequest(.snoozeNextAd(broadcasterID: actorID), credentials)
      },
      .commercial: { credentials, actorID in
        try makeIdentityRequest(
          .startCommercial(length: 30, broadcasterID: actorID), credentials)
      },
      .chatters: { credentials, actorID in
        try makeIdentityRequest(
          .getChatters(in: "channel", moderatorID: actorID), credentials)
      },
      .announcement: { credentials, actorID in
        try makeIdentityRequest(
          .sendAnnouncement(in: "channel", message: "hi", moderatorID: actorID),
          credentials)
      },
      .chatMessage: { credentials, actorID in
        try makeIdentityRequest(
          .sendChatMessage(in: "channel", message: "hi", senderID: actorID), credentials)
      },
      .shoutout: { credentials, actorID in
        try makeIdentityRequest(
          .sendShoutout(from: "channel", to: "target", moderatorID: actorID), credentials)
      },
      .chatSettings: { credentials, actorID in
        try makeIdentityRequest(
          .updateChatSettings(of: "channel", moderatorID: actorID, settings: []),
          credentials)
      },
      .addTerm: { credentials, actorID in
        try makeIdentityRequest(
          .addBlockedTerm(in: "channel", text: "term", moderatorID: actorID), credentials)
      },
      .ban: { credentials, actorID in
        try makeIdentityRequest(
          .banUser("target", in: "channel", moderatorID: actorID), credentials)
      },
      .checkAutoMod: { credentials, actorID in
        try makeIdentityRequest(
          .checkAutoModStatus(messages: [], broadcasterID: actorID), credentials)
      },
      .deleteMessage: { credentials, actorID in
        try makeIdentityRequest(
          .deleteChatMessage(in: "channel", messageID: "message", moderatorID: actorID),
          credentials)
      },
      .autoModSettings: { credentials, actorID in
        try makeIdentityRequest(
          .getAutoModSettings(of: "channel", moderatorID: actorID), credentials)
      },
      .bannedUsers: { credentials, actorID in
        try makeIdentityRequest(.getBannedUsers(broadcasterID: actorID), credentials)
      },
      .blockedTerms: { credentials, actorID in
        try makeIdentityRequest(
          .getBlockedTerms(in: "channel", moderatorID: actorID), credentials)
      },
      .moderatedChannels: { credentials, actorID in
        try makeIdentityRequest(.getModeratedChannels(userID: actorID), credentials)
      },
      .shieldStatus: { credentials, actorID in
        try makeIdentityRequest(
          .getShieldModeStatus(of: "channel", moderatorID: actorID), credentials)
      },
      .approveMessage: { credentials, actorID in
        try makeIdentityRequest(
          .approveAutoModMessage(messageID: "message", userID: actorID), credentials)
      },
      .denyMessage: { credentials, actorID in
        try makeIdentityRequest(
          .denyAutoModMessage(messageID: "message", userID: actorID), credentials)
      },
      .removeTerm: { credentials, actorID in
        try makeIdentityRequest(
          .removeBlockedTerm(in: "channel", termID: "term", moderatorID: actorID),
          credentials)
      },
      .unban: { credentials, actorID in
        try makeIdentityRequest(
          .unbanUser("target", in: "channel", moderatorID: actorID), credentials)
      },
      .updateAutoMod: { credentials, actorID in
        try makeIdentityRequest(
          .updateAutoModSettings(of: "channel", overall: 1, moderatorID: actorID),
          credentials)
      },
      .updateShield: { credentials, actorID in
        try makeIdentityRequest(
          .updateShieldModeStatus(of: "channel", isActive: true, moderatorID: actorID),
          credentials)
      },
      .subscribers: { credentials, actorID in
        try makeIdentityRequest(.getSubscribers(broadcasterID: actorID), credentials)
      },
      .channelTeams: { credentials, actorID in
        try makeIdentityRequest(.getChannelTeams(for: actorID), credentials)
      },
      .pinnedMessage: { credentials, actorID in
        try makeIdentityRequest(
          .getPinnedChatMessage(in: "channel", moderatorID: actorID), credentials)
      },
      .pinMessage: { credentials, actorID in
        try makeIdentityRequest(
          .pinChatMessage("message", in: "channel", moderatorID: actorID), credentials)
      },
      .updatePin: { credentials, actorID in
        try makeIdentityRequest(
          .updatePinnedChatMessage("message", in: "channel", moderatorID: actorID),
          credentials)
      },
      .unpinMessage: { credentials, actorID in
        try makeIdentityRequest(
          .unpinChatMessage("message", in: "channel", moderatorID: actorID), credentials)
      },
      .vodClip: { credentials, actorID in
        try makeIdentityRequest(
          .createClipFromVOD(
            "vod", broadcasterID: "channel", vodOffset: 60, title: "Clip",
            editorID: actorID), credentials)
      },
      .clipDownloads: { credentials, actorID in
        try makeIdentityRequest(
          .getClipsDownload(["clip"], broadcasterID: "channel", editorID: actorID),
          credentials)
      },
      .addSuspicious: { credentials, actorID in
        try makeIdentityRequest(
          .addSuspiciousStatusToChatUser(
            "target", in: "channel", status: .restricted, moderatorID: actorID),
          credentials)
      },
      .removeSuspicious: { credentials, actorID in
        try makeIdentityRequest(
          .removeSuspiciousStatusFromChatUser(
            "target", in: "channel", moderatorID: actorID), credentials)
      },
      .warnUser: { credentials, actorID in
        try makeIdentityRequest(
          .warnChatUser("target", in: "channel", reason: "reason", moderatorID: actorID),
          credentials)
      },
      .activeExtensions: { credentials, actorID in
        try makeIdentityRequest(.getUserActiveExtensions(userID: actorID), credentials)
      },
    ]
}

private func makeIdentityRequest<
  R, H: Decodable & Sendable, E: HelixEndpointResponseType
>(
  _ endpoint: HelixEndpoint<R, H, E>, _ credentials: TwitchCredentials
) throws -> URLRequest {
  try endpoint.makeRequest(using: credentials, encoder: TwitchClient.makeEncoder())
}
