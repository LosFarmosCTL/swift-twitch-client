import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == BitsLeaderboard, HelixResponseType == BitsLeaderboardEntry
{
  public static func getBitsLeaderboard(
    count: Int? = nil,
    period: BitsLeaderboardPeriod? = nil,
    startedAt: Date? = nil,
    userID: UserID? = nil
  ) -> Self {
    return .init(
      method: "GET", path: "bits/leaderboard",
      queryItems: { _ in
        [
          ("count", count.map(String.init)),
          ("period", period?.rawValue),
          ("started_at", startedAt?.formatted(.iso8601)),
          ("user_id", userID),
        ]
      },
      makeResponse: {
        guard let total = $0.total else {
          throw HelixError.missingDataInResponse(responseData: $0.rawData)
        }

        return BitsLeaderboard(
          leaders: $0.data,
          total: total,
          startDate: $0.dateRange?.startedAt,
          endDate: $0.dateRange?.endedAt)
      })
  }
}

public enum BitsLeaderboardPeriod: String, Sendable {
  case day, week, month, year, all
}

public struct BitsLeaderboard: Sendable {
  public let leaders: [BitsLeaderboardEntry]
  public let total: Int
  public let startDate: Date?
  public let endDate: Date?
}

public struct BitsLeaderboardEntry: Decodable, Sendable {
  public let userID: String
  public let userLogin: String
  public let userName: String
  public let rank: Int
  public let score: Int

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin, userName
    case rank, score
  }
}
