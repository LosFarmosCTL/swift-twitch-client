import Foundation

extension HelixEndpoint {
  public static func addBlockedTerm(
    in broadcasterID: String,
    text: String
  ) -> HelixEndpoint<BlockedTerm, BlockedTerm, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "POST", path: "moderation/blocked_terms",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID),
          ("moderator_id", credentials.userID),
        ]
      },
      body: { _ in ["text": text] },
      makeResponse: {
        let term = try $0.requireFirst()

        return term
      })
  }
}
