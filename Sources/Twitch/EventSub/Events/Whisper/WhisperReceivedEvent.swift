public struct WhisperReceivedEvent: Event {
  public let fromUserID: String
  public let fromUserName: String
  public let fromUserLogin: String

  public let toUserID: String
  public let toUserName: String
  public let toUserLogin: String

  public let whisperID: String
  public let whisper: String

  enum CodingKeys: String, CodingKey {
    case fromUserID = "fromUserId"
    case fromUserName, fromUserLogin

    case toUserID = "toUserId"
    case toUserName, toUserLogin

    case whisperID = "whisperId"
    case whisper
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    fromUserID = try container.decode(String.self, forKey: .fromUserID)
    fromUserName = try container.decode(String.self, forKey: .fromUserName)
    fromUserLogin = try container.decode(String.self, forKey: .fromUserLogin)

    toUserID = try container.decode(String.self, forKey: .toUserID)
    toUserName = try container.decode(String.self, forKey: .toUserName)
    toUserLogin = try container.decode(String.self, forKey: .toUserLogin)

    whisperID = try container.decode(String.self, forKey: .whisperID)

    let whisperMessage = try container.decode(WhisperMessage.self, forKey: .whisper)
    self.whisper = whisperMessage.text
  }

  struct WhisperMessage: Decodable, Sendable {
    public let text: String
  }
}
