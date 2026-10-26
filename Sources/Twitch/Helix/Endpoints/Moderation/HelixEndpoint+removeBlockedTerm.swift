import Foundation

extension HelixEndpoint {
  public static func removeBlockedTerm(
    in broadcasterID: String, termID: String
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "DELETE", path: "moderation/blocked_terms",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("moderator_id", credentials.userID),
          ("id", termID),
        ]
      })
  }
}
