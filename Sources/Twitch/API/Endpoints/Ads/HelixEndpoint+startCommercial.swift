import Foundation

extension HelixEndpoint where Response == ResponseTypes.Data<Commercial> {
  public static func startCommercial(broadcasterId: String, length: Int) -> Self {
    .init(
      method: "POST", path: "channels/commercial",
      body: StartCommercialRequestBody(broadcasterId: broadcasterId, length: length))
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
