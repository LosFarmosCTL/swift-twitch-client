import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func addBlockedTerm(inChannel broadcasterID: String, text: String) async throws
    -> BlockedTerm
  {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterID), ("moderator_id", self.authenticatedUserId))

    let (rawResponse, result): (_, HelixData<BlockedTerm>?) = try await self.request(
      .post("moderation/blocked_terms"), with: queryItems, jsonBody: ["text": text])

    guard let term = result?.data.first else {
      throw HelixError.invalidResponse(rawResponse: rawResponse)
    }

    return term
  }
}
