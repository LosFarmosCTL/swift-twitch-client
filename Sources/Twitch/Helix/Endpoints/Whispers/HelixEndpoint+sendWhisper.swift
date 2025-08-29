import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Void,
  ResponseType == EmptyResponse, HelixResponseType == EmptyResponse
{
  public static func sendWhisper(
    to receiver: UserID, message: String
  ) -> Self {
    return .init(
      method: "POST", path: "whispers",
      queryItems: { auth in
        [
          ("from_user_id", auth.userID),
          ("to_user_id", receiver),
        ]
      },
      body: { _ in Whisper(message: message) })
  }
}

internal struct Whisper: Encodable, Sendable { let message: String }
