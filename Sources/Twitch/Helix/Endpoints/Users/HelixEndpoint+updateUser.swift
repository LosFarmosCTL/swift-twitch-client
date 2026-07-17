import Foundation

extension HelixEndpoint {
  public static func updateUser(description: String)
    -> HelixEndpoint<User, User, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "PUT", path: "users",
      queryItems: { _ in
        [("description", description)]
      },
      makeResponse: {
        let user = try $0.requireFirst()

        return user
      })
  }
}
