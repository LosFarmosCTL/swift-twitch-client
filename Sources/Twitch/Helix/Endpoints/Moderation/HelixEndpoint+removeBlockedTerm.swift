import Foundation

extension HelixEndpoint {
  public static func removeBlockedTerm(
    in channel: String, termID: String
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
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
