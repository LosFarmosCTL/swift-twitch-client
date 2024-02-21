import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<BadgeSet> {
  public static func getGlobalBadges() -> Self {
    return .init(method: "GET", path: "chat/badges/global")
  }
}
