import Foundation
import Testing
import TwitchIRC

@testable import Twitch

extension ManagedChatTests {
  @Test(arguments: ["unbounded", "oldest", "newest"])
  func messageBufferingPreservesTheSelectedEventsWithoutCancellingMembership(
    policy: String
  )
    async throws
  {
    var instance: TwitchClient? = client()
    let callbacks = AsyncStream<IRCListenerEvent>.makeStream()
    // Discarding the value-type cancellation handle must leave its observer active.
    _ = await instance!.ircMessageListener { callbacks.continuation.yield($0) }
    #expect(await session.taskCount() == 0)

    try await instance!.requestJoin(to: channel)
    let socket = await session.waitForTask(at: 0)
    await handshake(socket)
    await acknowledge(socket)
    _ = await callbacks.stream.first {
      if case .message(let delivery) = $0, case .roomState = delivery.message {
        true
      } else {
        false
      }
    }
    let messages = await instance!.messageStream(bufferingPolicy: bufferingPolicy(policy))
    let raw = await instance!.ircMessageStream(bufferingPolicy: bufferingPolicy(policy))

    for name in ["first", "second", "third"] {
      await socket.simulateIncoming(
        .string(
          "@msg-id=observer_test :tmi.twitch.tv NOTICE #swift :\(name)"))
    }
    // A raw callback is delivered only after normalization has buffered that message.
    let callbackMessages = await callbackNotices(from: callbacks.stream, count: 3)
    #expect(await instance!.chatState.channels[channel.id]?.status == .ready)
    #expect(await !socket.didCancel)
    // Owner teardown finishes buffers without adding a membership-departure event.
    instance = nil
    await socket.waitForCancellation()

    let expected =
      policy == "unbounded"
      ? ["first", "second", "third"]
      : policy == "oldest" ? ["first", "second"] : ["second", "third"]
    var received: [String] = []
    for await event in messages {
      if case .notice(_, let text) = event.payload { received.append(text) }
    }
    var rawReceived: [String] = []
    for await event in raw {
      if case .notice(let notice) = event.message {
        rawReceived.append(noticeText(notice))
      }
    }
    #expect(received == expected)
    #expect(rawReceived == expected)
    #expect(callbackMessages == ["first", "second", "third"])
    #expect(await session.taskCount() == 1)
  }

  @Test
  func stateSnapshotsCoalesceToTheLatestRevisionAndFinishOnShutdown() async {
    let client = client()
    let states = await client.chatStateUpdates()
    await client.switchCredentials(to: first)
    await client.switchCredentials(to: second)
    await client.shutdownChat()

    var snapshots: [ChatState] = []
    for await state in states { snapshots.append(state) }
    #expect(snapshots.count == 1)
    #expect(snapshots.first?.isShutdown == true)
    #expect(snapshots.first?.credentialRevision == 2)
    #expect(snapshots.first?.userID == second.userID)
    #expect(await session.taskCount() == 0)
  }

  private func callbackNotices(from events: AsyncStream<IRCListenerEvent>, count: Int)
    async -> [String]
  {
    var messages: [String] = []
    for await event in events {
      if case .message(let delivery) = event, case .notice(let notice) = delivery.message {
        messages.append(noticeText(notice))
      }
      if messages.count == count { break }
    }
    return messages
  }

  private func bufferingPolicy<Element>(
    _ name: String
  ) -> AsyncStream<Element>.Continuation.BufferingPolicy {
    switch name {
    case "oldest": .bufferingOldest(2)
    case "newest": .bufferingNewest(2)
    default: .unbounded
    }
  }
}

private func noticeText(_ notice: Notice) -> String {
  switch notice.kind {
  case .local(_, let text, _), .unknownLocal(_, let text, _): text
  default: ""
  }
}
