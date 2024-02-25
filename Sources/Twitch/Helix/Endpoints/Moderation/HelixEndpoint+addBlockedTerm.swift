import Foundation

extension HelixEndpoint where Response == ResponseTypes.Object<BlockedTerm> {
  public static func addBlockedTerm(
    inChannel broadcasterID: String, text: String, moderatorID: String
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterID),
      ("moderator_id", moderatorID))

    return .init(
      method: "POST", path: "moderation/blocked_terms", queryItems: queryItems,
      body: ["text": text])
  }
}
