import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == [UserColor],
  HelixResponseType == UserColor
{
  public static func getUserColors(of users: [UserID]) -> Self {
    return .init(
      method: "GET", path: "chat/color",
      queryItems: { _ in
        users.map { ("user_id", $0) }
      }, makeResponse: { $0.data })
  }
}

public struct UserColor: Decodable {
  let userID: String
  let userLogin: String
  let userName: String
  let color: String

  enum CodingKeys: String, CodingKey {
    case userID = "user_id"
    case userLogin = "user_login"
    case userName = "user_name"
    case color
  }
}
