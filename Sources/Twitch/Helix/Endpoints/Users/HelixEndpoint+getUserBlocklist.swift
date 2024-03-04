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
  let userID: String
  let userLogin: String
  let displayName: String

  enum CodingKeys: String, CodingKey {
    case userID = "user_id"
    case userLogin = "user_login"
    case displayName = "display_name"
  }
}
