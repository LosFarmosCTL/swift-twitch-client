import Foundation

extension HelixEndpoint {
  public static func sendAnnouncement(
    in channel: String,
    message: String,
    color: AnnouncementColor? = nil
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "POST", path: "chat/announcements",
      queryItems: { auth in
        [
          ("broadcaster_id", channel),
          ("moderator_id", auth.userID),
        ]
      }, body: { _ in SendAnnouncementRequestBody(message: message, color: color) })
  }
}

internal struct SendAnnouncementRequestBody: Encodable, Sendable {
  let message: String
  let color: AnnouncementColor?
}

public enum AnnouncementColor: String, Encodable, Sendable {
  case blue, green, orange, purple, primary
}
