import Foundation

extension HelixEndpoint {
  /// Gets downloadable analytics reports for extensions owned by the authenticated user.
  ///
  /// With a user access token, requires `analytics:read:extensions`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/analytics/#get-extension-analytics
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - extensionID: The identifier of the extension, when provided.
  ///   - type: The analytics report format; Twitch currently supports `"overview_v2"`.
  ///   - range: The date interval used to restrict the results.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - cursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields matching items and a pagination cursor when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func getExtensionAnalytics(
    extensionID: String? = nil,
    type: String? = nil,
    range: DateInterval? = nil,
    limit: Int? = nil,
    after cursor: String? = nil
  ) -> HelixEndpoint<ExtensionAnalyticsResponse> {
    .init(
      method: "GET", path: "analytics/extensions",
      authentication: .user,
      queryItems: { _ in
        [
          ("extension_id", extensionID),
          ("type", type),
          ("started_at", range?.start.formatted(.iso8601)),
          ("ended_at", range?.end.formatted(.iso8601)),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ]
      }, responseType: ExtensionReport.self,
      makeResponse: {
        ExtensionAnalyticsResponse(reports: $0.data, cursor: $0.pagination?.cursor)
      })
  }
}

/// A downloadable extension analytics report and its covered date range.
public struct ExtensionReport: Decodable, Sendable {
  /// The identifier of the extension.
  public let extensionID: String
  /// The URL associated with this resource.
  public let url: String
  /// The analytics report format requested from Twitch.
  public let type: String
  /// The date range covered by the response.
  public let range: DateInterval

  /// Creates an `ExtensionReport` value.
  public init(
    extensionID: String,
    url: String,
    type: String,
    range: DateInterval
  ) {
    self.extensionID = extensionID
    self.url = url
    self.type = type
    self.range = range
  }

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

    guard endedAt >= startedAt else {
      throw DecodingError.dataCorruptedError(
        forKey: .endedAt, in: rangeContainer,
        debugDescription: "ended_at must not precede started_at")
    }

    self.range = DateInterval(start: startedAt, end: endedAt)
  }
}

/// A page of extension analytics.
public struct ExtensionAnalyticsResponse: Sendable {
  /// The reports on this page.
  public let reports: [ExtensionReport]
  /// The next-page cursor, if Twitch returned one.
  public let cursor: String?

  /// Creates an `ExtensionAnalyticsResponse` value.
  public init(
    reports: [ExtensionReport] = [],
    cursor: String? = nil
  ) {
    self.reports = reports
    self.cursor = cursor
  }
}
