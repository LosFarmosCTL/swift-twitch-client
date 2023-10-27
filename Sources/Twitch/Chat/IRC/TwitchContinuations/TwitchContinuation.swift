import TwitchIRC

internal protocol TwitchContinuation {
  func check(message: IncomingMessage) async
}
