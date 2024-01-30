import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func sendWhisper(to userID: String, message: String) async throws {
    let queryItems = self.makeQueryItems(
      ("from_user_id", self.authenticatedUserId), ("to_user_id", userID))

    (_, _) =
      try await self.request(
        .post("whispers"), with: queryItems, jsonBody: Whisper(message: message))
      as (_, HelixData<Int>?)
  }
}

internal struct Whisper: Encodable { let message: String }
