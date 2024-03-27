import Foundation

public typealias EmoteSetID = String

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == EmoteSetResponse,
  HelixResponseType == SetEmote
{
  public static func getEmoteSets(_ sets: [EmoteSetID]) -> Self {
    return .init(
      method: "GET", path: "chat/emotes/set",
      queryItems: { _ in
        sets.map { ("emote_set_id", $0) }
      },
      makeResponse: {
        guard let template = $0.template else {
          throw HelixError.missingDataInResponse
        }

        return EmoteSetResponse(emotes: $0.data, template: template)
      }
    )
  }
}

public struct EmoteSetResponse: Decodable {
  public let emotes: [SetEmote]

  public let template: String
}

public struct SetEmote: Decodable {
  public let id: String
  public let name: String
  public let type: String
  public let setID: String
  public let ownerID: String
  public let format: [Emote.Format]
  public let scale: [Emote.Scale]
  public let themeMode: [Emote.ThemeMode]

  enum CodingKeys: String, CodingKey {
    case id = "id"
    case name = "name"
    case type = "emote_type"
    case setID = "emote_set_id"
    case ownerID = "owner_id"
    case format = "format"
    case scale = "scale"
    case themeMode = "theme_mode"
  }

  public func getURL(
    from templateUrl: String, format: Emote.Format = .png, scale: Emote.Scale = .large,
    themeMode: Emote.ThemeMode = .dark
  ) -> URL? {
    return URL(
      string: templateUrl.replacingOccurrences(of: "{{id}}", with: self.id)
        .replacingOccurrences(of: "{{scale}}", with: scale.rawValue).replacingOccurrences(
          of: "{{format}}", with: format.rawValue
        ).replacingOccurrences(of: "{{theme_mode}}", with: themeMode.rawValue))
  }
}
