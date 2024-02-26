import Foundation

extension HelixEndpoint where Response == ResponseTypes.Void {
  public static func removeBlockedTerm(
    in channel: UserID, termID: String, moderatorID: String
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", channel),
      ("moderator_id", moderatorID),
      ("id", termID))

    return .init(
      method: "DELETE", path: "moderation/blocked_terms", queryItems: queryItems)
  }
}
