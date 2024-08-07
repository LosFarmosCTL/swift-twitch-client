import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == [BlockedUser], HelixResponseType == BlockedUser
{
  public static func getBlocklist(
    limit: Int? = nil, after cursor: String? = nil
  ) -> Self {
    return .init(
      method: "GET", path: "users/blocks",
      queryItems: { auth in
        [
          ("broadcaster_id", auth.userID),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ]
      },
      makeResponse: {
        $0.data
      })
  }
}

public struct BlockedUser: Decodable {
  public let userID: String
  public let userLogin: String
  public let displayName: String

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case displayName
  }
}
