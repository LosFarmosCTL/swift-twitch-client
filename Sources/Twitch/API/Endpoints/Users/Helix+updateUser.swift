import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func updateUser(description: String) async throws -> User {
    let queryItems = self.makeQueryItems(("description", description))

    let (rawResponse, result): (_, HelixData<User>?) = try await self.request(
      .put("users"), with: queryItems)

    guard let user = result?.data.first else {
      throw HelixError.invalidResponse(rawResponse: rawResponse)
    }

    return user
  }
}
