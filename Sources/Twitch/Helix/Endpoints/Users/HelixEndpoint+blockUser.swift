import Foundation

extension HelixEndpoint {
  public static func blockUser(
    _ userID: String,
    sourceContext: UserBlockSourceContext? = nil,
    reason: UserBlockReason? = nil
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "PUT", path: "users/blocks",
      queryItems: { _ in
        [
          ("target_user_id", userID),
          ("source_context", sourceContext?.rawValue),
          ("reason", reason?.rawValue),
        ]
      })
  }
}

public enum UserBlockSourceContext: String, Decodable, Sendable { case chat, whisper }
public enum UserBlockReason: String, Decodable, Sendable { case harassment, spam, other }
