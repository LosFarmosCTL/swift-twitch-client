import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func deleteChatMessage(inChannel broadcasterID: String, withID messageID: String)
    async throws
  {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterID), ("moderator_id", self.authenticatedUserId),
      ("message_id", messageID))

    (_, _) =
      try await self.request(.delete("moderation/chat"), with: queryItems)
      as (_, HelixData<BlockedTerm>?)
  }
}
