import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getGlobalEmotes() async throws -> (
    templateUrl: String, emotes: [GlobalEmote]
  ) {
    let (rawResponse, result): (_, HelixData<GlobalEmote>?) = try await self.request(
      .get("chat/emotes/global"))

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }
    guard let template = result.template else {
      throw HelixError.invalidResponse(rawResponse: rawResponse)
    }

    return (template, result.data)
  }
}

public struct GlobalEmote: Decodable {
  let id: String
  let name: String
  let format: [Emote.Format]
  let scale: [Emote.Scale]
  let themeMode: [Emote.ThemeMode]

  enum CodingKeys: String, CodingKey {
    case id = "id"
    case name = "name"
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
