import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Void,
  ResponseType == EmptyResponse, HelixResponseType == EmptyResponse
{
  public static func removeBlockedTerm(
    in channel: String, termID: String
  ) -> Self {
    return .init(
      method: "DELETE", path: "moderation/blocked_terms",
      queryItems: { auth in
        [
          ("broadcaster_id", channel),
          ("moderator_id", auth.userID),
          ("id", termID),
        ]
      })
  }
}
