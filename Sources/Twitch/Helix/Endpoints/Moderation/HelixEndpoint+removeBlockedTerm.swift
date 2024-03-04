import Foundation

extension HelixEndpoint where EndpointResponseType == HelixEndpointResponseTypes.Void {
  public static func removeBlockedTerm(
    in channel: UserID, termID: String
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
