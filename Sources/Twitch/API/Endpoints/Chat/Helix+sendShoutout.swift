import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func sendShoutout(from sendingUserId: String, to receivingUserId: String)
    async throws
  {
    let queryItems = self.makeQueryItems(
      ("from_broadcaster_id", sendingUserId), ("to_broadcaster_id", receivingUserId),
      ("moderator_id", self.authenticatedUserId))

    (_, _) =
      try await self.request(.post("chat/announcements"), with: queryItems)
      as (_, HelixData<Int>?)
  }
}
