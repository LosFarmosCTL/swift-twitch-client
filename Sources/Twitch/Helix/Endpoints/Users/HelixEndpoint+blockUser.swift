import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Void,
  ResponseType == EmptyResponse, HelixResponseType == EmptyResponse
{
  public static func block(
    _ user: String, sourceContext: SourceContext? = nil, reason: Reason? = nil
  ) -> Self {
    return .init(
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
