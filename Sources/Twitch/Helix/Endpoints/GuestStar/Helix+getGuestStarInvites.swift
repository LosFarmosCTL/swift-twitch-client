import Foundation

extension HelixEndpoint {
  public static func getGuestStarInvites(
    broadcasterID: String? = nil,
    moderatorID: String? = nil,
    sessionID: String
  ) -> HelixEndpoint<
    [GuestStarInvite], GuestStarInvite,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "guest_star/invites",
      queryItems: { auth in
        [
          ("broadcaster_id", broadcasterID ?? auth.userID),
          ("moderator_id", moderatorID ?? auth.userID),
          ("session_id", sessionID),
        ]
      },
      makeResponse: { $0.data })
  }
}

public struct GuestStarInvite: Decodable, Sendable {
  public let userID: String
  public let invitedAt: Date
  public let status: GuestStarInviteStatus
  public let isVideoEnabled: Bool
  public let isAudioEnabled: Bool
  public let isVideoAvailable: Bool
  public let isAudioAvailable: Bool

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case invitedAt
    case status
    case isVideoEnabled
    case isAudioEnabled
    case isVideoAvailable
    case isAudioAvailable
  }
}

public enum GuestStarInviteStatus: String, Codable, Sendable {
  case invited = "INVITED"
  case accepted = "ACCEPTED"
  case ready = "READY"
}
