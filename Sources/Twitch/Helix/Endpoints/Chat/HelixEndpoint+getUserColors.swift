import Foundation

extension HelixEndpoint {
  /// Gets the chat name colors of the requested users.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/chat/#get-user-chat-color
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - userIDs: The user IDs to include in the request.
  public static func getUserColors(
    of userIDs: [String]
  ) -> HelixEndpoint<[UserColor]> {
    .init(
      method: "GET", path: "chat/color",
      authentication: .either,
      queryItems: { _ in
        userIDs.map { ("user_id", $0) }
      }, responseType: UserColor.self, makeResponse: { $0.data })
  }
}

/// A user’s chat display color.
public struct UserColor: Decodable, Sendable {
  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The user’s display name.
  public let userDisplayName: String
  /// The color reported by Twitch.
  public let color: String

  /// Creates a `UserColor` value.
  public init(
    userID: String,
    userLogin: String,
    userDisplayName: String,
    color: String
  ) {
    self.userID = userID
    self.userLogin = userLogin
    self.userDisplayName = userDisplayName
    self.color = color
  }

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case color
  }
}
