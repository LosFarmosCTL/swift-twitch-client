import Foundation

extension HelixEndpoint {
  /// Gets polls from the authenticated broadcaster’s channel.
  ///
  /// With a user access token, requires `channel:read:polls` or `channel:manage:polls`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/polls/#get-polls
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `broadcaster_id`.
  ///
  /// - Parameters:
  ///   - pollIDs: The poll IDs to include in the request. Defaults to `[]`.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - cursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields matching items and a pagination cursor when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func getPolls(
    pollIDs: [String] = [],
    limit: Int? = nil,
    after cursor: String? = nil
  ) -> HelixEndpoint<PollsResponse> {
    .init(
      method: "GET", path: "polls",
      authentication: .user,
      queryItems: { credentials in
        [
          ("broadcaster_id", try credentials.requireUser().id),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ] + pollIDs.map { ("id", $0) }
      },
      responseType: Poll.self,
      makeResponse: { PollsResponse(polls: $0.data, cursor: $0.pagination?.cursor) })
  }
}

/// A channel poll’s choices, voting configuration, lifecycle state, and timing.
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

  /// Creates a `Poll` value.
  public init(
    id: String,
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    title: String,
    choices: [PollChoice] = [],
    channelPointsVotingEnabled: Bool,
    channelPointsPerVote: Int,
    status: PollStatus,
    duration: Int,
    startedAt: Date,
    endedAt: Date? = nil
  ) {
    self.id = id
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.title = title
    self.choices = choices
    self.channelPointsVotingEnabled = channelPointsVotingEnabled
    self.channelPointsPerVote = channelPointsPerVote
    self.status = status
    self.duration = duration
    self.startedAt = startedAt
    self.endedAt = endedAt
  }

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
public struct PollChoice: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The title shown to viewers.
  public let title: String
  /// The number of votes for this choice.
  public let votes: Int
  /// The number of votes purchased using Channel Points.
  public let channelPointsVotes: Int

  /// Creates a `PollChoice` value.
  public init(
    id: String,
    title: String,
    votes: Int,
    channelPointsVotes: Int
  ) {
    self.id = id
    self.title = title
    self.votes = votes
    self.channelPointsVotes = channelPointsVotes
  }
}

/// A poll’s voting, completion, moderation, or archival state, preserving unfamiliar
/// values in `rawValue`.
public struct PollStatus: RawRepresentable, Decodable, Sendable, Hashable {
  /// The exact poll status string supplied by Twitch or the caller.
  public let rawValue: String

  /// Creates a poll status from any raw string.
  public init(rawValue: String) { self.rawValue = rawValue }

  /// Decodes a poll status from a single string.
  public init(from decoder: Decoder) throws {
    self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
  }

  /// The poll or prediction is accepting participation. Encoded as `"ACTIVE"`.
  public static let active = Self(rawValue: "ACTIVE")
  /// The poll completed normally. Encoded as `"COMPLETED"`.
  public static let completed = Self(rawValue: "COMPLETED")
  /// The poll ended before its scheduled completion. Encoded as `"TERMINATED"`.
  public static let terminated = Self(rawValue: "TERMINATED")
  /// The poll was archived. Encoded as `"ARCHIVED"`.
  public static let archived = Self(rawValue: "ARCHIVED")
  /// The poll was deleted. Still documented for Create Poll and End Poll responses.
  public static let moderated = Self(rawValue: "MODERATED")
  /// The poll is not valid. Encoded as `"INVALID"`.
  public static let invalid = Self(rawValue: "INVALID")
}

/// A page of polls.
public struct PollsResponse: Sendable {
  /// The polls on this page.
  public let polls: [Poll]
  /// The next-page cursor, if Twitch returned one.
  public let cursor: String?

  /// Creates a `PollsResponse` value.
  public init(
    polls: [Poll] = [],
    cursor: String? = nil
  ) {
    self.polls = polls
    self.cursor = cursor
  }
}
