public struct NOTICE: IRCMessage {
  public let rawIRCTags: [String: String]
  public let rawIRCMessage: String

  public let channel: String?
  public let message: String

  internal let msgId: String

  public var type: NoticeType { return NoticeType(id: msgId) }
}

public enum NoticeType {
  case unrecognizedCommand
  case channelSuspended
  case accountSuspended
  case duplicateMessage
  case emoteOnly
  case followersOnly
  case subOnly
  case r9k
  case slowMode
  case timedOut
  case messageRejected
  case banned
  case verifiedPhoneNumberRequired
  case verifiedEmailRequired

  case unknown(typeId: String)

  // swiftlint:disable cyclomatic_complexity
  internal init(id: String) {
    switch id {
    case "unrecognized_command": self = .unrecognizedCommand
    case "msg_channel_suspended": self = .channelSuspended
    case "msg_suspended": self = .accountSuspended
    case "msg_duplicate": self = .duplicateMessage
    case "msg_emoteonly": self = .emoteOnly
    case "msg_followersonly", "msg_followersonly_zero": self = .followersOnly
    case "msg_subonly": self = .subOnly
    case "msg_r9k": self = .r9k
    case "msg_slowmode": self = .slowMode
    case "msg_timedout": self = .timedOut
    case "msg_rejected_mandatory": self = .messageRejected
    case "msg_banned": self = .banned
    case "msg_requires_verified_phone_number":
      self = .verifiedPhoneNumberRequired
    case "msg_verified_email": self = .verifiedEmailRequired
    default: self = .unknown(typeId: id)
    }
  }

}
