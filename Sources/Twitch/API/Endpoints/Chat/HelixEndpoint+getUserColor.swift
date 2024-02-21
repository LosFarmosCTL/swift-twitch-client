import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<UserColor> {
  public static func getUserColor(userIDs: [String]) -> Self {
    let queryItems = userIDs.map { URLQueryItem(name: "user_id", value: $0) }

    return .init(method: "GET", path: "chat/color", queryItems: queryItems)
  }
}

public struct UserColor: Decodable {
  let userId: String
  let userLogin: String
  let userName: String
  let color: String

  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case userLogin = "user_login"
    case userName = "user_name"
    case color
  }
}
