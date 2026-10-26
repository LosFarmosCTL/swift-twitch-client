import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getChannelEditors()
    -> HelixEndpoint<[Editor], Editor, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "GET", path: "channels/editors",
      queryItems: { credentials in
        [("broadcaster_id", credentials.userID)]
      },
      makeResponse: { $0.data })
  }
}

@MemberwiseInit(.public)
public struct Editor: Decodable, Sendable {
  public let userID: String
  public let userDisplayName: String
  public let createdAt: Date

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userDisplayName = "userName"
    case createdAt
  }
}
