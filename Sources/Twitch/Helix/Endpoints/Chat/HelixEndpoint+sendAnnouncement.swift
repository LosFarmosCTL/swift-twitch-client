import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Void,
  ResponseType == EmptyResponse, HelixResponseType == EmptyResponse
{
  public static func sendAnnouncement(
    in channel: UserID, message: String, color: AnnouncementColor? = nil
  ) -> Self {
    return .init(
      method: "POST", path: "chat/announcements",
      queryItems: { auth in
        [
          ("broadcaster_id", channel),
          ("moderator_id", auth.userID),
        ]
      }, body: { _ in SendAnnouncementRequestBody(message: message, color: color) })
  }
}

internal struct SendAnnouncementRequestBody: Encodable {
  let message: String
  let color: AnnouncementColor?
}

public enum AnnouncementColor: String, Encodable {
  case blue, green, orange, purple, primary
}
