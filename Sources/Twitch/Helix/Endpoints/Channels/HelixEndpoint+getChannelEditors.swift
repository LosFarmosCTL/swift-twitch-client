import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<Editor> {
  public static func getChannelEditors(broadcasterID: String) -> Self {
    let queryItems = makeQueryItems(("broadcaster_id", broadcasterID))

    return .init(method: "GET", path: "channels/editors", queryItems: queryItems)
  }
}

public struct Editor: Decodable {
  let userID: String
  let userName: String
  let createdAt: Date

  enum CodingKeys: String, CodingKey {
    case userID = "user_id"
    case userName = "user_name"
    case createdAt = "created_at"
  }
}
