import Foundation

extension HelixEndpoint {
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

public enum PollEndStatus: String, Encodable, Sendable {
  case terminated = "TERMINATED"
  case archived = "ARCHIVED"
}

private struct EndPollRequestBody: Encodable, Sendable {
  let broadcasterID: String
  let id: String
  let status: PollEndStatus
}
