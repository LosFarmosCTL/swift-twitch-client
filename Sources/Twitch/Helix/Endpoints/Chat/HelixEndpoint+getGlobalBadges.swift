import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == [BadgeSet], HelixResponseType == BadgeSet
{
  public static func getGlobalBadges() -> Self {
    return .init(method: "GET", path: "chat/badges/global", makeResponse: { $0.data })
  }
}
