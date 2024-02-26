import Foundation

extension HelixEndpoint where Response == ResponseTypes.Void {
  public static func sendWhisper(
    from sender: UserID, to receiver: UserID, message: String
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("from_user_id", sender),
      ("to_user_id", receiver))

    return .init(
      method: "POST", path: "whispers", queryItems: queryItems,
      body: Whisper(message: message))
  }
}

internal struct Whisper: Encodable { let message: String }
