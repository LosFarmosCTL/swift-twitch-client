import Foundation

extension HelixEndpoint where Response == ResponseTypes.Void {
  public static func block(
    _ user: UserID, sourceContext: SourceContext? = nil, reason: Reason? = nil
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("target_user_id", user),
      ("source_context", sourceContext?.rawValue),
      ("reason", reason?.rawValue))

    return .init(method: "PUT", path: "users/blocks", queryItems: queryItems)
  }
}

public enum SourceContext: String, Decodable { case chat, whisper }
public enum Reason: String, Decodable { case harassment, spam, other }
