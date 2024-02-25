import Foundation

extension HelixEndpoint where Response == ResponseTypes.Void {
  public static func sendAnnouncement(
    broadcasterID: String, message: String, color: AnnouncementColor? = nil,
    moderatorID: String
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterID),
      ("moderator_id", moderatorID))

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
