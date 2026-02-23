public struct ChannelGuestStarGuestUpdateEvent: Event {
  public let broadcasterID: String
  public let broadcasterName: String
  public let broadcasterLogin: String

  public let moderatorID: String?
  public let moderatorName: String?
  public let moderatorLogin: String?

  public let guestID: String?
  public let guestName: String?
  public let guestLogin: String?

  public let hostID: String
  public let hostName: String
  public let hostLogin: String

  public let sessionID: String
  public let slotID: String?
  public let state: State?

  public let hostVideoEnabled: Bool?
  public let hostAudioEnabled: Bool?
  public let hostVolume: Int?

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterName = "broadcasterUserName"
    case broadcasterLogin = "broadcasterUserLogin"

    case moderatorID = "moderatorUserId"
    case moderatorName = "moderatorUserName"
    case moderatorLogin = "moderatorUserLogin"

    case guestID = "guestUserId"
    case guestName = "guestUserName"
    case guestLogin = "guestUserLogin"

    case hostID = "hostUserId"
    case hostName = "hostUserName"
    case hostLogin = "hostUserLogin"

    case sessionID = "sessionId"
    case slotID = "slotId"
    case state

    case hostVideoEnabled, hostAudioEnabled, hostVolume
  }

  public enum State: String, Codable, Sendable {
    case invited
    case accepted
    case ready
    case backstage
    case live
    case removed
  }
}
