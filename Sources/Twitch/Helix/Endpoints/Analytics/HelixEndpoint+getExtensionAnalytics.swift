import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets downloadable analytics reports for extensions owned by the authenticated user.
  ///
  /// With a user access token, requires `analytics:read:extensions`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-extension-analytics
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - extensionID: The identifier of the extension, when provided.
  ///   - type: The analytics report format; Twitch currently supports `"overview_v2"`.
  ///   - range: The date interval used to restrict the results.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - afterCursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields matching items and a pagination cursor when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func getExtensionAnalytics(
    extensionID: String? = nil,
    type: String? = nil,
    range: DateInterval? = nil,
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    (reports: [ExtensionReport], cursor: String?),
    ExtensionReport, HelixEndpointResponseTypes.Normal
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
          ("after", afterCursor),
        ]
      }, makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

/// A downloadable extension analytics report and its covered date range.
@MemberwiseInit(.public)
public struct ExtensionReport: Decodable, Sendable {
  /// The identifier of the extension.
  public let extensionID: String
  /// The URL associated with this resource.
  public let url: String
  /// The analytics report format requested from Twitch.
  public let type: String
  /// The date range covered by the response.
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

  /// Decodes a report, combining its start and end timestamps into `range`.
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
