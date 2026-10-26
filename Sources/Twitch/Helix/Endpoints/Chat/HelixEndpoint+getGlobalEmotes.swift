import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getGlobalEmotes()
    -> HelixEndpoint<GlobalEmotesResponse, GlobalEmote, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "GET", path: "chat/emotes/global",
      makeResponse: {
        let template = try $0.require(\.template)

        return GlobalEmotesResponse(emotes: $0.data, template: template)

      })
  }
}

public struct GlobalEmotesResponse: Sendable {
  public let emotes: [GlobalEmote]

  public let template: String
}

@MemberwiseInit(.public)
public struct GlobalEmote: Decodable, Sendable {
  public let id: String
  public let name: String
  public let format: [Emote.Format]
  public let scale: [Emote.Scale]
  public let themeMode: [Emote.ThemeMode]

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
