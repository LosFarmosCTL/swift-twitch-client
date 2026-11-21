import Testing

@testable import Twitch

extension ManagedChatEventSubTests {
  @Test(arguments: [(false, false), (true, false), (true, true)])
  func eventSubNormalizesActionAndEmoteOccurrences(isAction: Bool, framedFragments: Bool)
    async throws
  {
    let client = await client()
    let events = await client.messageStream()
    try await client.join(to: channel)

    let intro = "👩🏽‍💻 e\u{0301} "
    let text = intro + "Kappa PogChamp Kappa"
    let wireText = isAction ? "\u{1}ACTION \(text)\u{1}" : text
    let fragments: [[String: Any]] =
      [
        ["type": "text", "text": framedFragments ? "\u{1}ACTION \(intro)" : intro],
        ["type": "emote", "text": "Kappa", "emote": emoteFragmentMetadata(id: "25")],
        ["type": "text", "text": " "],
        ["type": "emote", "text": "PogChamp", "emote": emoteFragmentMetadata(id: "88")],
        ["type": "text", "text": " "],
        ["type": "emote", "text": "Kappa", "emote": emoteFragmentMetadata(id: "25")],
      ] + (framedFragments ? [["type": "text", "text": "\u{1}"]] : [])
    let payload = try notification(
      MockedMessages.channelChatMessage, type: "channel.chat.message"
    ) {
      var event = $0
      event["message"] = ["text": wireText, "fragments": fragments]
      return event
    }
    await session.simulateIncoming(.string(payload))

    var messages = events.compactMap { event in
      if case .message(let message) = event.payload { message } else { nil }
    }.makeAsyncIterator()
    let message = try #require(await messages.next())
    #expect(message.text == text)
    #expect(message.isAction == isAction)
    #expect(message.emotes.map(\.id) == ["25", "88", "25"])
    #expect(message.emotes.map(\.name) == ["Kappa", "PogChamp", "Kappa"])
    #expect(message.emotes.map(\.range.unicodeScalarOffsets) == [8..<13, 14..<22, 23..<28])
    #expect(message.emotes.map { $0.range.text(in: message.text) } == message.emotes.map(\.name))
    if case .eventSub(let original) = message.details {
      #expect(original.messageType == .text)
      #expect(original.message.text == wireText)
      #expect(
        original.message.fragments.map(\.text) == fragments.compactMap { $0["text"] as? String })
    } else {
      Issue.record("Expected the original EventSub payload")
    }
    await client.shutdownChat()
    await client.resetEventSub()
  }

  private func emoteFragmentMetadata(id: String) -> [String: Any] {
    ["id": id, "emote_set_id": "0", "owner_id": "0", "format": ["static"]]
  }
}
