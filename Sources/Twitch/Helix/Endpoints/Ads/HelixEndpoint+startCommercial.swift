import Foundation

extension HelixEndpoint where Response == ResponseTypes.Object<Commercial> {
  public static func startCommercial(on channel: UserID, length: Int) -> Self {
    .init(
      method: "POST", path: "channels/commercial",
      body: StartCommercialRequestBody(broadcasterID: channel, length: length))
  }
}

private struct StartCommercialRequestBody: Encodable {
  let broadcasterID: String
  let length: Int

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcaster_id"
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
