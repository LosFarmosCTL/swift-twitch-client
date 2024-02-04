import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func approveAutomodMessage(withID msgID: String) async throws {
    try await self.handleAutomodMessage(withID: msgID, action: "APPROVE")
  }

  public func denyAutomodMessage(withID msgID: String) async throws {
    try await self.handleAutomodMessage(withID: msgID, action: "DENY")
  }

  private func handleAutomodMessage(withID msgID: String, action: String) async throws {
    let (_, _) =
      try await self.request(
        .post("moderation/automod/message"),
        jsonBody: [
          "data": [
            "user_id": self.authenticatedUserId, "msg_id": msgID, "action": action,
          ]
        ]) as (_, HelixData<Int>?)
  }
}
