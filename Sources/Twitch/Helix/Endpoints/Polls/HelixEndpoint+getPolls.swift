import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets polls from the authenticated broadcaster’s channel.
  ///
  /// With a user access token, requires `channel:read:polls` or `channel:manage:polls`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-polls
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `broadcaster_id`.
  ///
  /// - Parameters:
  ///   - pollIDs: The poll IDs to include in the request. Defaults to `[]`.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - afterCursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields matching items and a pagination cursor when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func getPolls(
    pollIDs: [String] = [],
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    (polls: [Poll], cursor: String?),
    Poll, HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "polls",
      authentication: .user,
      queryItems: { credentials in
        [
          ("broadcaster_id", try credentials.requireUser().id),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ] + pollIDs.map { ("id", $0) }
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

/// A channel poll’s choices, voting configuration, lifecycle state, and timing.
@MemberwiseInit(.public)
public struct Poll: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String

  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The title shown to viewers.
  public let title: String
  /// The poll choices.
  public let choices: [PollChoice]

  /// Whether viewers can purchase additional votes with Channel Points.
  public let channelPointsVotingEnabled: Bool
  /// The Channel Points required for each additional vote.
  public let channelPointsPerVote: Int

  /// The poll’s voting, completion, or archival state.
  public let status: PollStatus
  /// The poll duration, in seconds.
  public let duration: Int

  /// The time the activity started.
  public let startedAt: Date
  /// The time the activity ended, when provided.
  public let endedAt: Date?

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterId"
    case broadcasterLogin
    case broadcasterDisplayName = "broadcasterName"
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

/// A poll choice and its accumulated votes.
@MemberwiseInit(.public)
public struct PollChoice: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The title shown to viewers.
  public let title: String
  /// The number of votes for this choice.
  public let votes: Int
  /// The number of votes purchased using Channel Points.
  public let channelPointsVotes: Int
  /// The number of votes purchased using Bits.
  public let bitsVotes: Int
}

/// A poll’s voting, completion, moderation, or archival state.
public enum PollStatus: String, Decodable, Sendable {
  /// The poll or prediction is accepting participation. Encoded as `"ACTIVE"`.
  case active = "ACTIVE"
  /// The poll completed normally. Encoded as `"COMPLETED"`.
  case completed = "COMPLETED"
  /// The poll ended before its scheduled completion. Encoded as `"TERMINATED"`.
  case terminated = "TERMINATED"
  /// The poll was archived. Encoded as `"ARCHIVED"`.
  case archived = "ARCHIVED"
  /// The poll was removed by moderation. Encoded as `"MODERATED"`.
  case moderated = "MODERATED"
  /// The poll is not valid. Encoded as `"INVALID"`.
  case invalid = "INVALID"
}
