import Foundation
import TwitchIRC

/// Validates untrusted fields before serializing an outgoing IRC command.
internal struct IRCWireMessage: Sendable {
  let text: String

  init(_ message: OutgoingMessage) throws {
    let prepared: OutgoingMessage

    switch message {
    case .privateMessage(let channel, let text, let replyID, let nonce):
      try Self.validateText(text, parameter: "message")
      if let replyID { try Self.validateTag(replyID, parameter: "replyToMessageID") }
      if let nonce { try Self.validateTag(nonce, parameter: "clientNonce") }
      prepared = .privateMessage(
        to: try Self.normalizeChannel(channel), message: text,
        messageIDToReply: replyID, clientNonce: nonce)
    case .join(let channel):
      prepared = .join(to: try Self.normalizeChannel(channel))
    case .part(let channel):
      prepared = .part(from: try Self.normalizeChannel(channel))
    case .nick(let login):
      guard Self.isLogin(login) else {
        throw IRCError.invalidInput(parameter: "userLogin")
      }
      prepared = message
    case .pass(let token):
      try Self.validateText(token, parameter: "accessToken")
      guard !token.isEmpty, !token.contains(where: \.isWhitespace) else {
        throw IRCError.invalidInput(parameter: "accessToken")
      }
      prepared = message
    case .capabilities, .ping, .pong:
      prepared = message
    }

    text = prepared.serialize()
  }

  static let anonymousLogin = "justinfan12345"

  static func login(for credentials: TwitchCredentials?) -> String {
    credentials?.userLogin?.lowercased() ?? anonymousLogin
  }

  static func channelLogin(_ channel: String) -> String {
    String(channel.drop(while: { $0 == "#" })).lowercased()
  }

  static func normalizeChannel(_ channel: String) throws -> String {
    let login = channelLogin(channel)
    guard isLogin(login) else { throw IRCError.invalidInput(parameter: "channel") }
    return login
  }

  static func validateCredentials(_ credentials: TwitchCredentials) throws {
    let user = try credentials.requireUser()
    _ = try Self(.nick(name: user.login))
    _ = try Self(.pass(pass: credentials.accessToken))
  }

  static func isLogin(_ login: String) -> Bool {
    !login.isEmpty && login.utf8.count <= 25
      && login.utf8.allSatisfy {
        (97...122).contains($0) || (48...57).contains($0) || $0 == 95
      }
  }

  static func isSafeText(_ text: String) -> Bool {
    !text.utf8.contains(where: { $0 == 0 || $0 == 10 || $0 == 13 })
  }

  private static func validateText(_ text: String, parameter: String) throws {
    guard isSafeText(text) else {
      throw IRCError.invalidInput(parameter: parameter)
    }
  }

  private static func validateTag(_ value: String, parameter: String) throws {
    guard !value.utf8.contains(0) else {
      throw IRCError.invalidInput(parameter: parameter)
    }
  }
}
