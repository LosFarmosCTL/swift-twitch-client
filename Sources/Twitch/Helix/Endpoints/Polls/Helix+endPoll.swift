import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == Poll, HelixResponseType == Poll
{
  public static func endPoll(id: String, status: PollEndStatus) -> Self {
    return .init(
      method: "PATCH", path: "polls",
      body: { auth in
        EndPollRequestBody(
          broadcasterID: auth.userID,
          id: id,
          status: status)
      },
      makeResponse: {
        guard let poll = $0.data.first else {
          throw HelixError.noDataInResponse(responseData: $0.rawData)
        }

        return poll
      })
  }
}

public enum PollEndStatus: String, Encodable, Sendable {
  case terminated = "TERMINATED"
  case archived = "ARCHIVED"
}

internal struct EndPollRequestBody: Encodable, Sendable {
  let broadcasterID: String
  let id: String
  let status: PollEndStatus
}
