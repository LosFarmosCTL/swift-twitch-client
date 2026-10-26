import Foundation

extension HelixEndpoint {
  /// Starts a poll in the authenticated broadcaster’s channel.
  ///
  /// With a user access token, requires `channel:manage:polls`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#create-poll
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - title: The title shown to viewers.
  ///   - choices: The titles of the poll choices.
  ///   - duration: The poll duration, in seconds.
  ///   - channelPointsVotingEnabled: Whether viewers can purchase additional votes with
  ///     Channel Points, when provided.
  ///   - channelPointsPerVote: The Channel Points required for each additional vote, when
  ///     provided.
  public static func createPoll(
    title: String,
    choices: [String],
    duration: Int,
    channelPointsVotingEnabled: Bool? = nil,
    channelPointsPerVote: Int? = nil
  ) -> HelixEndpoint<Poll, Poll, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "POST", path: "polls",
      body: { credentials in
        CreatePollRequestBody(
          broadcasterID: credentials.userID,
          title: title,
          choices: choices.map { .init(title: $0) },
          duration: duration,
          channelPointsVotingEnabled: channelPointsVotingEnabled,
          channelPointsPerVote: channelPointsPerVote)
      },
      makeResponse: {
        let poll = try $0.requireFirst()

        return poll
      })
  }
}

internal struct CreatePollRequestBody: Encodable, Sendable {
  let broadcasterID: String
  let title: String
  let choices: [Choice]
  let duration: Int
  let channelPointsVotingEnabled: Bool?
  let channelPointsPerVote: Int?

  struct Choice: Encodable, Sendable {
    let title: String
  }
}
