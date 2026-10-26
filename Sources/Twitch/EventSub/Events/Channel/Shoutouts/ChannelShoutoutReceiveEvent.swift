import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct ChannelShoutoutReceiveEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let fromBroadcasterID: String
  public let fromBroadcasterLogin: String
  public let fromBroadcasterDisplayName: String

  public let viewerCount: Int
  public let startedAt: Date

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case fromBroadcasterID = "fromBroadcasterUserId"
    case fromBroadcasterLogin = "fromBroadcasterUserLogin"
    case fromBroadcasterDisplayName = "fromBroadcasterUserName"
    case viewerCount
    case startedAt
  }
}
