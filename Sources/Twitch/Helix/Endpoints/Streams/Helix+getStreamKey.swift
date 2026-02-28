import Foundation

extension HelixEndpoint {
  public static func getStreamKey()
    -> HelixEndpoint<String, StreamKey, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "GET", path: "streams/key",
      queryItems: { auth in
        [
          ("broadcaster_id", auth.userID)
        ]
      },
      makeResponse: { response in
        guard let key = response.data.first else {
          throw HelixError.noDataInResponse(responseData: response.rawData)
        }

        return key.streamKey
      })
  }
}

public struct StreamKey: Decodable, Sendable {
  public let streamKey: String
}
