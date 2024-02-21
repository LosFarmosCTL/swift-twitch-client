import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<SetEmote> {
  public static func getEmoteSets(setIds: [String]) -> Self {
    let queryItems = setIds.map { URLQueryItem(name: "emote_set_id", value: $0) }

    return .init(method: "GET", path: "chat/emotes/set", queryItems: queryItems)
  }
}

public struct SetEmote: Decodable {
  let id: String
  let name: String
  let type: String
  let setId: String
  let ownerId: String
  let format: [Emote.Format]
  let scale: [Emote.Scale]
  let themeMode: [Emote.ThemeMode]

  enum CodingKeys: String, CodingKey {
    case id = "id"
    case name = "name"
    case type = "emote_type"
    case setId = "emote_set_id"
    case ownerId = "owner_id"
    case format = "format"
    case scale = "scale"
    case themeMode = "theme_mode"
  }

  func getURL(
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
