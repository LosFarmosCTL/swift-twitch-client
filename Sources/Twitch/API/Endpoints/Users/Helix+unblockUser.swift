import Foundation

extension HelixEndpoint where Response == ResponseTypes.Void {
  public static func unblockUser(withID userID: String) -> Self {
    let queryItems = self.makeQueryItems(("target_user_id", userID))

    return .init(method: "DELETE", path: "users/blocks", queryItems: queryItems)
  }
}
