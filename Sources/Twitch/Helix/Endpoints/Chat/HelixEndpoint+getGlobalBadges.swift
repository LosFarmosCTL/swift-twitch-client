import Foundation

extension HelixEndpoint {
  public static func getGlobalBadges()
    -> HelixEndpoint<[BadgeSet], BadgeSet, HelixEndpointResponseTypes.Normal>
  {
    .init(method: "GET", path: "chat/badges/global", makeResponse: { $0.data })
  }
}
