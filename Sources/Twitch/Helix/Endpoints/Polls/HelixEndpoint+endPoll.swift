import Foundation

extension HelixEndpoint {
  /// Terminates or archives a poll.
  ///
  /// With a user access token, requires `channel:manage:polls`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#end-poll
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - pollID: The identifier of the poll.
  ///   - status: The requested status or status filter.
  public static func endPoll(
    pollID: String,
    status: PollEndStatus
  ) -> HelixEndpoint<Poll, Poll, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "PATCH", path: "polls",
      body: { credentials in
        EndPollRequestBody(
          broadcasterID: credentials.userID,
          id: pollID,
          status: status)
      },
      makeResponse: {
        let poll = try $0.requireFirst()

        return poll
      })
  }
}

/// The requested transition to terminate or archive a poll.
public enum PollEndStatus: String, Encodable, Sendable {
  /// Ends the poll before its scheduled completion. Encoded as `"TERMINATED"`.
  case terminated = "TERMINATED"
  /// Archives the poll. Encoded as `"ARCHIVED"`.
  case archived = "ARCHIVED"
}

private struct EndPollRequestBody: Encodable, Sendable {
  let broadcasterID: String
  let id: String
  let status: PollEndStatus
}
