import MemberwiseInit

@MemberwiseInit(.public)
public struct ChannelGuestStarGuestUpdateEvent: Event {
  public let broadcasterID: String
  public let broadcasterDisplayName: String
  public let broadcasterLogin: String

  public let moderatorID: String?
  public let moderatorDisplayName: String?
  public let moderatorLogin: String?

  public let guestID: String?
  public let guestDisplayName: String?
  public let guestLogin: String?

  public let hostID: String
  public let hostDisplayName: String
  public let hostLogin: String

  public let sessionID: String
  public let slotID: String?
  public let state: State?

  public let hostVideoEnabled: Bool?
  public let hostAudioEnabled: Bool?
  public let hostVolume: Int?

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterDisplayName = "broadcasterUserName"
    case broadcasterLogin = "broadcasterUserLogin"
    case moderatorID = "moderatorUserId"
    case moderatorDisplayName = "moderatorUserName"
    case moderatorLogin = "moderatorUserLogin"
    case guestID = "guestUserId"
    case guestDisplayName = "guestUserName"
    case guestLogin = "guestUserLogin"
    case hostID = "hostUserId"
    case hostDisplayName = "hostUserName"
    case hostLogin = "hostUserLogin"
    case sessionID = "sessionId"
    case slotID = "slotId"
    case state
    case hostVideoEnabled
    case hostAudioEnabled
    case hostVolume
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
