@testable import Twitch

extension TwitchIRCClient {
  func channelStatusSnapshots() -> AsyncStream<[String: IRCChannelStatus]> {
    distinctChannels(from: stateUpdates())
  }
}

extension IRCConnectionPool {
  func channelStatusSnapshots() -> AsyncStream<[String: IRCChannelStatus]> {
    distinctChannels(from: stateUpdates())
  }
}

private func distinctChannels(
  from updates: AsyncStream<IRCState>
) -> AsyncStream<[String: IRCChannelStatus]> {
  let (stream, continuation) = AsyncStream<[String: IRCChannelStatus]>.makeStream(
    bufferingPolicy: .bufferingNewest(1))

  let task = Task {
    var previous: [String: IRCChannelStatus]?

    for await state in updates where state.channels != previous {
      previous = state.channels
      continuation.yield(state.channels)
    }

    continuation.finish()
  }

  continuation.onTermination = { _ in
    task.cancel()
  }

  return stream
}
