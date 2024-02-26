import Foundation

extension HelixEndpoint where Response == ResponseTypes.Void {
  public static func unblock(_ user: UserID) -> Self {
    let queryItems = self.makeQueryItems(("target_user_id", user))

    return .init(method: "DELETE", path: "users/blocks", queryItems: queryItems)
  }
}
