import Foundation

extension HelixEndpoint {
  public static func getExtensionAnalytics(
    extensionID: String? = nil,
    type: String? = nil,
    range: DateInterval? = nil,
    limit: Int? = nil,
    after cursor: String? = nil
  ) -> HelixEndpoint<
    ([ExtensionReport], String?), ExtensionReport, HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "analytics/extensions",
      queryItems: { _ in
        [
          ("extension_id", extensionID),
          ("type", type),
          ("started_at", range?.start.formatted(.iso8601)),
          ("ended_at", range?.end.formatted(.iso8601)),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ]
      }, makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

public struct ExtensionReport: Decodable, Sendable {
  public let extensionID: String
  public let url: String
  public let type: String
  public let range: DateInterval

  enum CodingKeys: String, CodingKey {
    case extensionID = "extensionId"
    case url = "URL"
    case type
    case range = "dateRange"
  }

  enum DateRangeCodingKeys: String, CodingKey {
    case startedAt, endedAt
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.extensionID = try container.decode(String.self, forKey: .extensionID)
    self.url = try container.decode(String.self, forKey: .url)
    self.type = try container.decode(String.self, forKey: .type)

    let rangeContainer = try container.nestedContainer(
      keyedBy: DateRangeCodingKeys.self, forKey: .range)

    let startedAt = try rangeContainer.decode(Date.self, forKey: .startedAt)
    let endedAt = try rangeContainer.decode(Date.self, forKey: .endedAt)

    self.range = DateInterval(start: startedAt, end: endedAt)
  }
}
