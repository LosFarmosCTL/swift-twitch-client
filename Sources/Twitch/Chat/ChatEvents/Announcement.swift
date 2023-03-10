public struct Announcement {
  public let rawIRCTags: [String: String]
  public let rawIRCMessage: String

  public let message: ChatMessage

  public let announcementColor: AnnouncementColor

  public enum AnnouncementColor { case BLUE, GREEN, ORANGE, PURPLE, PRIMARY }
}
