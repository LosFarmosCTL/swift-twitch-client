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
        guard let user = $0.data.first else {
          throw HelixError.noDataInResponse(responseData: $0.rawData)
        }

        return user
      })
  }
}
