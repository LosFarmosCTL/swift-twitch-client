import Foundation
import TwitchIRC

internal protocol TwitchContinuation: Actor, Identifiable {
  func check(message: IncomingMessage) async -> Bool
  func setContinuation(_ continuation: CheckedContinuation<Void, any Error>)

  func cancel(throwing error: IRCError)
}
