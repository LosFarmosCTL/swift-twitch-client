import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func removeChannelVIP(userID: String) async throws {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", self.authenticatedUserId), ("user_id", userID))

    (_, _) =
      try await self.request(.delete("channels/vips"), with: queryItems)
      as (_, HelixData<Int>?)
  }
}
