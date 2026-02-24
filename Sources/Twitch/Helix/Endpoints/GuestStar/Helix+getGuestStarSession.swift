import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == GuestStarSession,
  HelixResponseType == GuestStarSession
{
  public static func getGuestStarSession(
    broadcasterID: UserID? = nil,
    moderatorID: UserID? = nil
  ) -> Self {
    return .init(
      method: "GET", path: "guest_star/session",
      queryItems: { auth in
        [
          ("broadcaster_id", broadcasterID ?? auth.userID),
          ("moderator_id", moderatorID ?? auth.userID),
        ]
      },
      makeResponse: { response in
        guard let session = response.data.first else {
          throw HelixError.noDataInResponse(responseData: response.rawData)
        }

        return session
      })
  }
}

public struct GuestStarSession: Decodable, Sendable {
  public let id: String
  public let guests: [GuestStarGuest]
}

public struct GuestStarGuest: Decodable, Sendable {
  public let slotID: String
  public let userID: String
  public let userDisplayName: String
  public let userLogin: String
  public let isLive: Bool
  public let volume: Int
  public let assignedAt: Date
  public let audioSettings: GuestStarMediaSettings
  public let videoSettings: GuestStarMediaSettings

  enum CodingKeys: String, CodingKey {
    case slotID = "slotId"
    case userID = "userId"
    case userDisplayName
    case userLogin
    case isLive
    case volume
    case assignedAt
    case audioSettings
    case videoSettings
  }
}

public struct GuestStarMediaSettings: Decodable, Sendable {
  public let isHostEnabled: Bool?
  public let isGuestEnabled: Bool?
  public let isAvailable: Bool
}
