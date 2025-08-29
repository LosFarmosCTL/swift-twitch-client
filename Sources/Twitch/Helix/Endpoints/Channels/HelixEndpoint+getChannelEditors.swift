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

public struct Editor: Decodable, Sendable {
  public let userID: String
  public let userName: String
  public let createdAt: Date

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userName, createdAt
  }
}
