import Foundation
import Testing

@testable import Twitch

extension ManagedChatEventSubTests {
  @Test
  func optionalRevocationKeepsChatAndVIPAndDeletionDedupSurvivesTransition() async throws {
    let client = await client(moderation: true)
    try await client.join(to: channel)
    let raw = try await client.eventStream(
      for: .channelChatMessageDelete(broadcasterID: channel.id, userID: "999"))
    let events = await client.messageStream()
    await client.setChatPrivilege(
      ChatPrivilege(isModerator: true, isVIP: true), in: channel.id)
    _ = try #require(
      await client.chatStateUpdates().first {
        $0.channels[self.channel.id]?.moderation == .ready
      })
    #expect(await postCount() == 7)

    await session.simulateIncoming(
      .string(try deletion(messageID: "deleted", envelopeID: "basic")))
    var rawIterator = raw.makeAsyncIterator()
    _ = try #require(try await rawIterator.next())
    await session.simulateIncoming(.string(try moderationDeletion(messageID: "deleted")))
    let deletedMessage = try #require(await nextDeletion(in: events))
    #expect(deletedMessage.text == "original text")
    #expect(deletedMessage.moderator?.id == "moderator")

    let later = await client.messageStream()
    await session.simulateIncoming(
      .string(
        MockedMessages.customized(
          MockedMessages.mockRevocationMessage.replacingOccurrences(
            of: "authorization_revoked", with: "new_authorization_reason"),
          subscriptionID: "channel.moderate-123")))
    let state = try #require(
      await client.chatStateUpdates().first {
        if case .failed = $0.channels[self.channel.id]?.moderation { true } else { false }
      })
    #expect(state.channels[channel.id]?.status == .ready)
    #expect(state.channels[channel.id]?.privilege.isVIP == true)
    #expect(state.channels[channel.id]?.privilege.isModerator == true)
    #expect(
      state.channels[channel.id]?.moderationRevocation?.rawValue == "new_authorization_reason")
    await session.simulateIncoming(
      .string(try deletion(messageID: "deleted", envelopeID: "duplicate")))
    await session.simulateIncoming(
      .string(try deletion(messageID: "next", envelopeID: "next")))
    let next = try #require(await nextDeletion(in: later))
    #expect(next.messageID == "next")
    #expect(next.text == nil)
    #expect(await postCount() == 7)
    await client.shutdownChat()
    await client.resetEventSub()
  }

  @Test
  func moderationRoleUpdatesDoNotPersistAnUnrelatedOverride() async throws {
    let client = await client(moderation: true)
    try await client.join(to: channel)
    let events = await client.messageStream()
    await client.setChatPrivilege(ChatPrivilege(isModerator: true, isVIP: true), in: channel.id)
    _ = try #require(
      await client.chatStateUpdates().first {
        $0.channels[self.channel.id]?.moderation == .ready
      })

    await session.simulateIncoming(
      .string(
        try notification(
          MockedMessages.channelModerateTimeoutUser, type: "channel.moderate",
          version: "2"
        ) {
          var event = $0
          event["action"] = "unvip"
          event["unvip"] = ["user_id": "999", "user_login": "sender", "user_name": "Sender"]
          return event
        }))
    _ = try #require(
      await events.first { if case .moderation = $0.payload { true } else { false } })

    await client.setChatPrivilege(nil, in: channel.id)
    let privilege = try #require(await client.chatState.channels[channel.id]?.privilege)
    #expect(privilege == ChatPrivilege())
    await client.shutdownChat()
    await client.resetEventSub()
  }

  @Test
  func moderationWithoutWarningsScopeDoesNotSubscribeToAnOlderVersion() async throws {
    let client = await client(moderation: true, warningScope: false)
    try await client.join(to: channel)
    await client.setChatPrivilege(ChatPrivilege(isModerator: true), in: channel.id)
    let state = await client.chatState
    #expect(state.channels[channel.id]?.status == .ready)
    #expect(
      state.channels[channel.id]?.moderation
        == .unavailable(
          "Required moderation scopes are not known to be granted."))
    #expect(await postCount() == 6)
    await client.shutdownChat()
  }

  @Test
  func lateModerationSetupCannotReviveEnrichmentAfterDemotion() async throws {
    let client = await client(moderation: true)
    try await client.join(to: channel)
    let gate = AsyncTestGate()
    let deleted = AsyncStream<Void>.makeStream()
    await session.onRequest { request in
      if request.httpMethod == "POST", let body = request.httpBody,
        let description = try? JSONSerialization.jsonObject(with: body) as? [String: Any],
        description["type"] as? String == "channel.moderate"
      {
        await gate.pause()
      }
      if request.httpMethod == "DELETE",
        request.url?.query?.contains("channel.moderate") == true
      {
        deleted.continuation.yield(())
      }
    }
    await client.setChatPrivilege(
      ChatPrivilege(isModerator: true, isVIP: true), in: channel.id)
    await gate.waitUntilEntered()
    await client.setChatPrivilege(ChatPrivilege(isVIP: true), in: channel.id)
    await gate.release()
    _ = await deleted.stream.first { _ in true }
    let state = await client.chatState
    #expect(state.channels[channel.id]?.status == .ready)
    #expect(state.channels[channel.id]?.privilege.isVIP == true)
    #expect(state.channels[channel.id]?.privilege.isModerator == false)
    #expect(
      {
        if case .unavailable = state.channels[channel.id]?.moderation {
          true
        } else {
          false
        }
      }())
    #expect(await postCount() == 7)
    await client.shutdownChat()
    await client.resetEventSub()
  }

  private func nextDeletion(in events: AsyncStream<ChatEvent>) async
    -> ChatMessageDeletion?
  {
    for await event in events {
      if case .messageDeleted(let deletion) = event.payload { return deletion }
    }
    return nil
  }

  private func deletion(messageID: String, envelopeID: String) throws -> String {
    try notification(
      MockedMessages.channelChatMessageDelete, type: "channel.chat.message_delete",
      envelopeID: envelopeID
    ) {
      var event = $0
      event["message_id"] = messageID
      return event
    }
  }

  private func moderationDeletion(messageID: String) throws -> String {
    try notification(
      MockedMessages.channelModerateTimeoutUser, type: "channel.moderate", version: "2"
    ) {
      var event = $0
      event["moderator_user_id"] = "moderator"
      event["action"] = "delete"
      event["delete"] = [
        "user_id": "author", "user_login": "author", "user_name": "Author",
        "message_id": messageID, "message_body": "original text",
      ]
      return event
    }
  }
}
