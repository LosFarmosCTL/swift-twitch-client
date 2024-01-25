import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func startCommercial(broadcasterId: String, length: Int) async throws
    -> Commercial?
  {
    var queryItems = [URLQueryItem]()
    queryItems.append(URLQueryItem(name: "broadcaster_id", value: broadcasterId))
    queryItems.append(URLQueryItem(name: "length", value: String(length)))

    return try await self.request(.get("channels"), with: queryItems).first
  }
}

public struct Commercial: Codable {
  let length: Int
  let message: String
  let retryAfter: Int

  enum CodingKeys: String, CodingKey {
    case length
    case message
    case retryAfter = "retry_after"
  }
}
