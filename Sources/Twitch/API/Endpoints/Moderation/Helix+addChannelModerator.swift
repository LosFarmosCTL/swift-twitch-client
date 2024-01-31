import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func addChannelModerator(userID: String) async throws {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", self.authenticatedUserId), ("user_id", userID))

    (_, _) =
      try await self.request(.post("moderation/moderators"), with: queryItems)
      as (_, HelixData<Int>?)
  }
}
