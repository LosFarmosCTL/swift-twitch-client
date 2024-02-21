import Foundation

extension HelixEndpoint where Response == ResponseTypes.Data<ExtensionReport> {
  public static func getExtensionAnalytics(
    extensionId: String? = nil, type: String? = nil, range: DateInterval? = nil,
    limit: Int? = nil, after cursor: String? = nil
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("extension_id", extensionId),
      ("type", type),
      ("started_at", range?.start.formatted(.iso8601)),
      ("ended_at", range?.end.formatted(.iso8601)),
      ("first", limit.map(String.init)),
      ("after", cursor))

    return .init(method: "GET", path: "analytics/extensions", queryItems: queryItems)
  }
}

public struct ExtensionReport: Decodable {
  let extensionId: String
  let url: String
  let type: String
  let range: DateInterval

  enum CodingKeys: String, CodingKey {
    case extensionId = "extension_id"
    case url = "URL"
    case type
    case range = "date_range"
  }

  enum DateRangeCodingKeys: String, CodingKey {
    case startedAt = "started_at"
    case endedAt = "ended_at"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.extensionId = try container.decode(String.self, forKey: .extensionId)
    self.url = try container.decode(String.self, forKey: .url)
    self.type = try container.decode(String.self, forKey: .type)

    let rangeContainer = try container.nestedContainer(
      keyedBy: DateRangeCodingKeys.self, forKey: .range)

    let startedAt = try rangeContainer.decode(Date.self, forKey: .startedAt)
    let endedAt = try rangeContainer.decode(Date.self, forKey: .endedAt)

    self.range = DateInterval(start: startedAt, end: endedAt)
  }
}
