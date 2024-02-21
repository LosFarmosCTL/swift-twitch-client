import Foundation

extension HelixEndpoint where Response == ResponseTypes.Void {
  public static func deleteChatMessage(
    inChannel broadcasterID: String, withID messageID: String, moderatorId: String
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterID),
      ("moderator_id", moderatorId),
      ("message_id", messageID))

    return .init(method: "DELETE", path: "moderation/chat", queryItems: queryItems)
  }
}
