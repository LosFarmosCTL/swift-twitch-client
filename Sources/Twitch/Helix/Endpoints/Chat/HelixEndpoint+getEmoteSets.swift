import Foundation
import MemberwiseInit

public typealias EmoteSetID = String

extension HelixEndpoint {
  public static func getEmoteSets(
    _ setIDs: [EmoteSetID]
  ) -> HelixEndpoint<EmoteSetsResponse, SetEmote, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "chat/emotes/set",
      queryItems: { _ in
        setIDs.map { ("emote_set_id", $0) }
      },
      makeResponse: {
        let template = try $0.require(\.template)

        return EmoteSetsResponse(emotes: $0.data, template: template)
      }
    )
  }
}

@MemberwiseInit(.public)
public struct EmoteSetsResponse: Decodable, Sendable {
  public let emotes: [SetEmote]

  public let template: String
}

@MemberwiseInit(.public)
public struct SetEmote: Decodable, Sendable {
  public let id: String
  public let name: String
  public let type: String
  public let setID: String
  public let ownerID: String
  public let format: [Emote.Format]
  public let scale: [Emote.Scale]
  public let themeMode: [Emote.ThemeMode]

  enum CodingKeys: String, CodingKey {
    case id, name
    case type = "emoteType"
    case setID = "emoteSetId"
    case ownerID = "ownerId"
    case format, scale, themeMode
  }

  public func getURL(
    from templateURL: String, format: Emote.Format = .png, scale: Emote.Scale = .large,
    themeMode: Emote.ThemeMode = .dark
  ) -> URL? {
    return URL(
      string: templateURL.replacingOccurrences(of: "{{id}}", with: self.id)
        .replacingOccurrences(of: "{{scale}}", with: scale.rawValue).replacingOccurrences(
          of: "{{format}}", with: format.rawValue
        ).replacingOccurrences(of: "{{theme_mode}}", with: themeMode.rawValue))
  }
}
