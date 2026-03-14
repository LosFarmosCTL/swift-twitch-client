import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getUserColors(
    of users: [String]
  ) -> HelixEndpoint<[UserColor], UserColor, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "chat/color",
      queryItems: { _ in
        users.map { ("user_id", $0) }
      }, makeResponse: { $0.data })
  }
}

@MemberwiseInit(.public)
public struct UserColor: Decodable, Sendable {
  public let userID: String
  public let userLogin: String
  public let userName: String
  public let color: String

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin, userName, color
  }
}
