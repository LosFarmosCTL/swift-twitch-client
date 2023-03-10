public struct ChatBadge {
  public let name: String
  public let version: String
  public let info: String?

  internal init?(from badgeString: String, with badgeInfo: [String]? = nil) {
    let badgeParts = badgeString.components(separatedBy: "/")
    guard badgeParts.count == 2 else { return nil }

    let name = badgeParts[0]
    let version = badgeParts[1]

    let info = badgeInfo?.first(where: { $0.hasPrefix(name) })?.components(
      separatedBy: ",")

    if info?.count == 2 { self.info = info?[1] } else { self.info = nil }

    self.name = name
    self.version = version
  }
}
