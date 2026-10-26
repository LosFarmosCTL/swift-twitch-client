import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct StreamOnlineEvent: Event {
  public let id: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let type: StreamType
  public let startedAt: Date

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case type
    case startedAt
  }

  public enum StreamType: String, Codable, Sendable {
    case live, playlist, premiere, rerun
    case watchParty = "watch_party"
  }
}
