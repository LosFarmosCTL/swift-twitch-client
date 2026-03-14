import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getChannelEditors()
    -> HelixEndpoint<[Editor], Editor, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "GET", path: "channels/editors",
      queryItems: { auth in
        [("broadcaster_id", auth.userID)]
      },
      makeResponse: { $0.data })
  }
}

@MemberwiseInit(.public)
public struct Editor: Decodable, Sendable {
  public let userID: String
  public let userName: String
  public let createdAt: Date

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userName, createdAt
  }
}
