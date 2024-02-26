import Foundation

// TODO: look into a way to maybe get rid of the `moderatorID` parameter
// and use the authenticated user's ID instead

extension HelixEndpoint where Response == ResponseTypes.Void {
  public static func sendAnnouncement(
    in channel: UserID, message: String, color: AnnouncementColor? = nil,
    moderatorID: UserID
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", channel),
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
