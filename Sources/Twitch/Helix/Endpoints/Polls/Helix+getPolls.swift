import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == ([Poll], PaginationCursor?),
  HelixResponseType == Poll
{
  public static func getPolls(
    filterIDs: [String] = [],
    limit: Int? = nil,
    after startCursor: String? = nil
  ) -> Self {
    return .init(
      method: "GET", path: "polls",
      queryItems: { auth in
        [
          ("broadcaster_id", auth.userID),
          ("first", limit.map(String.init)),
          ("after", startCursor),
        ] + filterIDs.map { ("id", $0) }
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

public struct Poll: Decodable, Sendable {
  public let id: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let title: String
  public let choices: [PollChoice]

  public let channelPointsVotingEnabled: Bool
  public let channelPointsPerVote: Int

  public let status: PollStatus
  public let duration: Int

  public let startedAt: Date
  public let endedAt: Date?

  enum CodingKeys: String, CodingKey {
    case id

    case broadcasterID = "broadcasterId"
    case broadcasterLogin
    case broadcasterName

    case title
    case choices

    case channelPointsVotingEnabled
    case channelPointsPerVote

    case status
    case duration

    case startedAt
    case endedAt
  }
}

public struct PollChoice: Decodable, Sendable {
  public let id: String
  public let title: String
  public let votes: Int
  public let channelPointsVotes: Int
  public let bitsVotes: Int
}

public enum PollStatus: String, Decodable, Sendable {
  case active = "ACTIVE"
  case completed = "COMPLETED"
  case terminated = "TERMINATED"
  case archived = "ARCHIVED"
  case moderated = "MODERATED"
  case invalid = "INVALID"
}
