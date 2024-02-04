import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getGlobalBadges() async throws -> [BadgeSet] {
    let (rawResponse, result): (_, HelixData<BadgeSet>?) = try await self.request(
      .get("chat/badges/global"))

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }

    return result.data
  }
}
