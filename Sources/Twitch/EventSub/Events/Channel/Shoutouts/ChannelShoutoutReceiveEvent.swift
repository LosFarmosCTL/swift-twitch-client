import Foundation

public struct ChannelShoutoutReceiveEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let fromBroadcasterID: String
  public let fromBroadcasterLogin: String
  public let fromBroadcasterName: String

  public let viewerCount: Int
  public let startedAt: Date

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"

    case fromBroadcasterID = "fromBroadcasterUserId"
    case fromBroadcasterLogin = "fromBroadcasterUserLogin"
    case fromBroadcasterName = "fromBroadcasterUserName"

    case viewerCount, startedAt
  }
}
