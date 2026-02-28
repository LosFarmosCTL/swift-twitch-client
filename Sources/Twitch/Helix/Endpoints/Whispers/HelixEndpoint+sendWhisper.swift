import Foundation

extension HelixEndpoint {
  public static func sendWhisper(
    to receiver: String,
    message: String
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
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
