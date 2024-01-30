import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func removeBlockedTerm(inChannel broadcasterID: String, termId: String)
    async throws
  {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterID), ("moderator_id", self.authenticatedUserId),
      ("id", termId))

    (_, _) =
      try await self.request(.delete("moderation/blocked_terms"), with: queryItems)
      as (_, HelixData<BlockedTerm>?)
  }
}
