import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == [Editor], HelixResponseType == Editor
{
  public static func getChannelEditors() -> Self {
    return .init(
      method: "GET", path: "channels/editors",
      queryItems: { auth in
        [("broadcaster_id", auth.userID)]
      }, makeResponse: { $0.data })
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
