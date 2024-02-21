import Foundation

extension HelixEndpoint where Response == ResponseTypes.Void {
  public static func sendWhisper(
    from senderId: String, to userID: String, message: String
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("from_user_id", senderId),
      ("to_user_id", userID))

    return .init(
      method: "POST", path: "whispers", queryItems: queryItems,
      body: Whisper(message: message))
  }
}

internal struct Whisper: Encodable { let message: String }
