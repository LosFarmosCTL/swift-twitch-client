import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == ([ModeratedChannel], PaginationCursor?),
  HelixResponseType == ModeratedChannel
{
  public static func getModeratedChannels(
    limit: Int? = nil, after cursor: String? = nil
  ) -> Self {
    return .init(
      method: "GET", path: "moderation/channels",
      queryItems: { auth in
        [
          ("user_id", auth.userID),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ]
      }, makeResponse: { ($0.data, $0.pagination?.cursor) }
    )
  }
}

public struct ModeratedChannel: Decodable {
  let id: String
  let login: String
  let displayName: String

  enum CodingKeys: String, CodingKey {
    case id = "broadcaster_id"
    case login = "broadcaster_login"
    case displayName = "broadcaster_name"
  }
}
