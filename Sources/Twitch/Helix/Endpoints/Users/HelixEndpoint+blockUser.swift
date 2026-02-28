import Foundation

extension HelixEndpoint {
  public static func block(
    _ user: String,
    sourceContext: SourceContext? = nil,
    reason: Reason? = nil
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "PUT", path: "users/blocks",
      queryItems: { _ in
        [
          ("target_user_id", user),
          ("source_context", sourceContext?.rawValue),
          ("reason", reason?.rawValue),
        ]
      })
  }
}

public enum SourceContext: String, Decodable, Sendable { case chat, whisper }
public enum Reason: String, Decodable, Sendable { case harassment, spam, other }
