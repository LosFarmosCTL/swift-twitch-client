public struct StreamOnlineEvent: Event {
  public let id: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let type: StreamType
  public let startedAt: String

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"

    case type, startedAt
  }

  public enum StreamType: String, Codable, Sendable {
    case live, playlist, premiere, rerun
    case watchParty = "watch_party"
  }
}
