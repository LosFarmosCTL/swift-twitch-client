import Foundation

extension HelixEndpoint where Response == ResponseTypes.Void {
  public static func removeBlockedTerm(
    inChannel broadcasterID: String, termId: String, moderatorId: String
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterID),
      ("moderator_id", moderatorId),
      ("id", termId))

    return .init(
      method: "DELETE", path: "moderation/blocked_terms", queryItems: queryItems)
  }
}
