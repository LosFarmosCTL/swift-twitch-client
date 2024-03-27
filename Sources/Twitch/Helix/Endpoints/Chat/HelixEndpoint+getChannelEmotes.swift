import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == ChannelEmotes, HelixResponseType == ChannelEmote
{
  public static func getChannelEmotes(of channel: UserID) -> Self {
    return .init(
      method: "GET", path: "chat/emotes",
      queryItems: { _ in [("broadcaster_id", channel)] },
      makeResponse: {
        guard let template = $0.template else {
          throw HelixError.missingDataInResponse
        }

        return ChannelEmotes(emotes: $0.data, template: template)
      })
  }
}

public struct ChannelEmotes {
  public let emotes: [ChannelEmote]

  public let template: String
}

public struct ChannelEmote: Decodable {
  public let id: String
  public let name: String
  public let tier: String?
  public let type: String
  public let setID: String
  public let format: [Emote.Format]
  public let scale: [Emote.Scale]
  public let themeMode: [Emote.ThemeMode]

  enum CodingKeys: String, CodingKey {
    case id = "id"
    case name = "name"
    case tier = "tier"
    case type = "emote_type"
    case setID = "emote_set_id"
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

public enum Emote {
  public enum Format: String, Decodable {
    case gif = "animated"
    case png = "static"
  }

  public enum Scale: String, Decodable {
    case small = "1.0"
    case medium = "2.0"
    case large = "3.0"
  }

  public enum ThemeMode: String, Decodable { case light, dark }
}
