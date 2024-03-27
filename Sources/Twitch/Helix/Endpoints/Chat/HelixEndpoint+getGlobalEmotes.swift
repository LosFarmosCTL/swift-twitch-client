import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == GlobalEmotes, HelixResponseType == GlobalEmote
{
  public static func getGlobalEmotes() -> Self {
    return .init(
      method: "GET", path: "chat/emotes/global",
      makeResponse: {
        guard let template = $0.template else {
          throw HelixError.missingDataInResponse
        }

        return GlobalEmotes(emotes: $0.data, template: template)

      })
  }
}

public struct GlobalEmotes {
  public let emotes: [GlobalEmote]

  public let template: String
}

public struct GlobalEmote: Decodable {
  public let id: String
  public let name: String
  public let format: [Emote.Format]
  public let scale: [Emote.Scale]
  public let themeMode: [Emote.ThemeMode]

  enum CodingKeys: String, CodingKey {
    case id = "id"
    case name = "name"
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
