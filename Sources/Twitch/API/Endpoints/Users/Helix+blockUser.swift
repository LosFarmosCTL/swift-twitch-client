import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func blockUser(
    withID userID: String, sourceContext: SourceContext? = nil, reason: Reason? = nil
  ) async throws {
    let queryItems = self.makeQueryItems(
      ("target_user_id", userID), ("source_context", sourceContext?.rawValue),
      ("reason", reason?.rawValue))

    let (_, _) =
      try await self.request(.put("users/blocks"), with: queryItems)
      as (_, HelixData<Int>?)
  }
}

public enum SourceContext: String, Decodable { case chat, whisper }
public enum Reason: String, Decodable { case harassment, spam, other }
