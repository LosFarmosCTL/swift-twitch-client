import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func sendAnnouncement(
    broadcasterId: String, message: String, color: AnnouncementColor? = nil
  ) async throws {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterId), ("moderator_id", self.authenticatedUserId))

    (_, _) =
      try await self.request(
        .post("chat/announcements"), with: queryItems,
        jsonBody: SendAnnouncementRequestBody(message: message, color: color))
      as (_, HelixData<Int>?)
  }
}

internal struct SendAnnouncementRequestBody: Encodable {
  let message: String
  let color: AnnouncementColor?
}

public enum AnnouncementColor: String, Encodable {
  case blue, green, orange, purple, primary
}
