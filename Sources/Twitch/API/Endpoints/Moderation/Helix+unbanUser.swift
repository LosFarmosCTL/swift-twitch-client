import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func unbanUser(withID userID: String, inChannel channelID: String) async throws {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", channelID), ("moderator_id", self.authenticatedUserId),
      ("user_id", userID))

    let (_, _) =
      try await self.request(.delete("moderation/bans"), with: queryItems)
      as (_, HelixData<Int>?)
  }
}
