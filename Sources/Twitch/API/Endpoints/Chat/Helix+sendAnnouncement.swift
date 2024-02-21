import Foundation

extension HelixEndpoint where Response == ResponseTypes.Void {
  public static func sendAnnouncement(
    broadcasterId: String, moderatorId: String, message: String,
    color: AnnouncementColor? = nil
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterId),
      ("moderator_id", moderatorId))

    return .init(
      method: "POST", path: "chat/announcements", queryItems: queryItems,
      body: SendAnnouncementRequestBody(message: message, color: color))
  }

}

internal struct SendAnnouncementRequestBody: Encodable {
  let message: String
  let color: AnnouncementColor?
}

public enum AnnouncementColor: String, Encodable {
  case blue, green, orange, purple, primary
}
