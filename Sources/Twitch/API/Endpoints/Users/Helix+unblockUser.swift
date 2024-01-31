import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func unblockUser(withID userID: String) async throws {
    let queryItems = self.makeQueryItems(("target_user_id", userID))

    let (_, _) =
      try await self.request(.delete("users/blocks"), with: queryItems)
      as (_, HelixData<Int>?)
  }
}
