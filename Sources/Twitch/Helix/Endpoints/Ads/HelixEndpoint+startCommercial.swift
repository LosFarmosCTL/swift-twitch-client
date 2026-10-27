import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Starts a commercial break in the authenticated broadcaster’s stream.
  ///
  /// With a user access token, requires `channel:edit:commercial`. App tokens have
  /// additional grant requirements described in the reference.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#start-commercial
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - broadcasterID: The acting user ID. Required with app tokens; otherwise defaults
  ///     to the user token’s identity.
  ///   - length: The commercial length, in seconds.
  public static func startCommercial(
    length: Int,
    broadcasterID: String? = nil
  ) -> HelixEndpoint<Commercial, Commercial, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "POST", path: "channels/commercial",
      authentication: .either,
      body: { credentials in
        StartCommercialRequestBody(
          broadcasterID: try credentials.resolveUserID(
            broadcasterID, parameter: "broadcaster_id", matchingToken: true),
          length: length)
      },
      makeResponse: { result in
        let response = try result.requireFirst()

        return response
      })
  }
}

private struct StartCommercialRequestBody: Encodable, Sendable {
  let broadcasterID: String
  let length: Int

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case length
  }
}

/// The result of starting a commercial, including its length and retry delay.
@MemberwiseInit(.public)
public struct Commercial: Decodable, Sendable {
  /// The commercial length, in seconds.
  public let length: Int
  /// The message content or explanatory text supplied by Twitch.
  public let message: String
  /// The number of seconds to wait before starting another commercial.
  public let retryAfter: Int
}
