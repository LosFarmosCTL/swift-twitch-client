import Foundation

extension HelixEndpoint {
  public static func sendWhisper(
    to toUserID: String,
    message: String
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "POST", path: "whispers",
      queryItems: { credentials in
        [
          ("from_user_id", credentials.userID),
          ("to_user_id", toUserID),
        ]
      },
      body: { _ in Whisper(message: message) })
  }
}

internal struct Whisper: Encodable, Sendable { let message: String }
