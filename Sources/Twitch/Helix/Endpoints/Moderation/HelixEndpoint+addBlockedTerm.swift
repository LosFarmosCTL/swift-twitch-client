import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == BlockedTerm, HelixResponseType == BlockedTerm
{
  public static func addBlockedTerm(
    in channel: String, text: String
  ) -> Self {
    return .init(
      method: "POST", path: "moderation/blocked_terms",
      queryItems: { auth in
        [
          ("broadcaster_id", channel),
          ("moderator_id", auth.userID),
        ]
      },
      body: { _ in ["text": text] },
      makeResponse: {
        guard let term = $0.data.first else {
          throw HelixError.noDataInResponse(responseData: $0.rawData)
        }

        return term
      })
  }
}
