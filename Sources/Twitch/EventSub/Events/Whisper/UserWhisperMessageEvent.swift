import MemberwiseInit

@MemberwiseInit(.public)
public struct UserWhisperMessageEvent: Event {
  public let fromUserID: String
  public let fromUserDisplayName: String
  public let fromUserLogin: String

  public let toUserID: String
  public let toUserDisplayName: String
  public let toUserLogin: String

  public let whisperID: String
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
    public let text: String
  }
}
