import MemberwiseInit

/// An EventSub notification delivered when a user receives a whisper.
@MemberwiseInit(.public)
public struct UserWhisperMessageEvent: Event {
  /// The Twitch user ID of the sending user.
  public let fromUserID: String
  /// The display name of the sending user.
  public let fromUserDisplayName: String
  /// The login name of the sending user.
  public let fromUserLogin: String

  /// The Twitch user ID of the receiving user.
  public let toUserID: String
  /// The display name of the receiving user.
  public let toUserDisplayName: String
  /// The login name of the receiving user.
  public let toUserLogin: String

  /// The identifier of the whisper.
  public let whisperID: String
  /// The text of the whisper.
  public let whisper: String

  enum CodingKeys: String, CodingKey {
    case fromUserID = "fromUserId"
    case fromUserDisplayName = "fromUserName"
    case fromUserLogin
    case toUserID = "toUserId"
    case toUserDisplayName = "toUserName"
    case toUserLogin
    case whisperID = "whisperId"
    case whisper
  }

  /// Decodes a whisper, exposing the nested message text as `whisper`.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    fromUserID = try container.decode(String.self, forKey: .fromUserID)
    fromUserDisplayName = try container.decode(String.self, forKey: .fromUserDisplayName)
    fromUserLogin = try container.decode(String.self, forKey: .fromUserLogin)

    toUserID = try container.decode(String.self, forKey: .toUserID)
    toUserDisplayName = try container.decode(String.self, forKey: .toUserDisplayName)
    toUserLogin = try container.decode(String.self, forKey: .toUserLogin)

    whisperID = try container.decode(String.self, forKey: .whisperID)

    let whisperMessage = try container.decode(WhisperMessage.self, forKey: .whisper)
    self.whisper = whisperMessage.text
  }

  struct WhisperMessage: Decodable, Sendable {
    /// The text content.
    public let text: String
  }
}
