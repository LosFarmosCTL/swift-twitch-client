import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getUserColor(userIDs: [String]) async throws -> [UserColor] {
    let queryItems = userIDs.map { URLQueryItem(name: "user_id", value: $0) }

    let (rawResponse, result): (_, HelixData<UserColor>?) = try await self.request(
      .get("chat/color"), with: queryItems)

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }

    return result.data
  }
}

public struct UserColor: Decodable {
  let userId: String
  let userLogin: String
  let userName: String
  let color: String

  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case userLogin = "user_login"
    case userName = "user_name"
    case color
  }
}
