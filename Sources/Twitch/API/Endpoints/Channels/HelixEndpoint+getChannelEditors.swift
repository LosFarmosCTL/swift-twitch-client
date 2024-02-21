import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<Editor> {
  public static func getChannelEditors(broadcasterId: String) -> Self {
    let queryItems = makeQueryItems(("broadcaster_id", broadcasterId))

    return .init(method: "GET", path: "channels/editors", queryItems: queryItems)
  }
}

public struct Editor: Decodable {
  let userId: String
  let userName: String
  let createdAt: Date

  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case userName = "user_name"
    case createdAt = "created_at"
  }
}
