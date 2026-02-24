import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == Poll, HelixResponseType == Poll
{
  public static func createPoll(
    title: String,
    choices: [String],
    duration: Int,
    channelPointsVotingEnabled: Bool? = nil,
    channelPointsPerVote: Int? = nil
  ) -> Self {
    return .init(
      method: "POST", path: "polls",
      body: { auth in
        CreatePollRequestBody(
          broadcasterID: auth.userID,
          title: title,
          choices: choices.map { .init(title: $0) },
          duration: duration,
          channelPointsVotingEnabled: channelPointsVotingEnabled,
          channelPointsPerVote: channelPointsPerVote)
      },
      makeResponse: {
        guard let poll = $0.data.first else {
          throw HelixError.noDataInResponse(responseData: $0.rawData)
        }

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
