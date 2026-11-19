import Foundation
import Testing

@testable import Twitch

extension ManagedChatEventSubTests {
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
        try notification(MockedMessages.channelModerateTimeoutUser, type: "channel.moderate") {
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
}
