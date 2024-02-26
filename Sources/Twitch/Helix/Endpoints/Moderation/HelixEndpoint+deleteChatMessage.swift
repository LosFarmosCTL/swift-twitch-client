import Foundation

extension HelixEndpoint where Response == ResponseTypes.Void {
  public static func deleteChatMessage(
    in channel: UserID, messageID: String, moderatorID: String
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", channel),
      ("moderator_id", moderatorID),
      ("message_id", messageID))

    return .init(method: "DELETE", path: "moderation/chat", queryItems: queryItems)
  }
}
