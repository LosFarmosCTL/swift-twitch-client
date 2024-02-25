import Foundation

extension HelixEndpoint where Response == ResponseTypes.Object<User> {
  public static func updateUser(description: String) -> Self {
    let queryItems = self.makeQueryItems(("description", description))

    return .init(method: "PUT", path: "users", queryItems: queryItems)
  }
}
