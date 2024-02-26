import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<UserColor> {
  public static func getUserColors(of users: [UserID]) -> Self {
    let queryItems = users.map { URLQueryItem(name: "user_id", value: $0) }

    return .init(method: "GET", path: "chat/color", queryItems: queryItems)
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
