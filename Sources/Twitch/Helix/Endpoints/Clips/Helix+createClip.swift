import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func createClip(
    broadcasterID: String? = nil,
    title: String? = nil,
    duration: Double? = nil
  ) -> HelixEndpoint<ClipCreation, ClipCreation, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "POST", path: "clips",
      queryItems: { auth in
        return [
          ("broadcaster_id", broadcasterID ?? auth.userID),
          ("title", title),
          ("duration", duration.map(String.init(describing:))),
        ]
      },
      makeResponse: {
        let clip = try $0.requireFirst()

        return clip
      })
  }
}

@MemberwiseInit(.public)
public struct ClipCreation: Decodable, Sendable {
  public let id: String
  public let editURL: String

  enum CodingKeys: String, CodingKey {
    case id
    case editURL = "editUrl"
  }
}
