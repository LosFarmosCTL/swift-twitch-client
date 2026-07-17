import Foundation

extension HelixEndpoint {
  public static func addBlockedTerm(
    in channel: String,
    text: String
  ) -> HelixEndpoint<BlockedTerm, BlockedTerm, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "POST", path: "moderation/blocked_terms",
      queryItems: { auth in
        [
          ("broadcaster_id", channel),
          ("moderator_id", auth.userID),
        ]
      },
      body: { _ in ["text": text] },
      makeResponse: {
        let term = try $0.requireFirst()

        return term
      })
  }
}
