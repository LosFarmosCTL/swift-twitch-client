import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func startCommercial(broadcasterId: String, length: Int) async throws
    -> Commercial
  {
    let (rawResponse, result): (_, HelixData<Commercial>?) = try await self.request(
      .post("channels/commercial"),
      jsonBody: StartCommercialRequestBody(broadcasterId: broadcasterId, length: length))

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }

    return result.data.first!
  }
}

private struct StartCommercialRequestBody: Encodable {
  let broadcasterId: String
  let length: Int

  enum CodingKeys: String, CodingKey {
    case broadcasterId = "broadcaster_id"
    case length
  }
}

public struct Commercial: Decodable {
  let length: Int
  let message: String
  let retryAfter: Int

  enum CodingKeys: String, CodingKey {
    case length
    case message
    case retryAfter = "retry_after"
  }
}
