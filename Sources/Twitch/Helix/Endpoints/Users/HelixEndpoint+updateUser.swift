import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == User, HelixResponseType == User
{
  public static func updateUser(description: String) -> Self {
    return .init(
      method: "PUT", path: "users",
      queryItems: { _ in
        [("description", description)]
      },
      makeResponse: {
        guard let user = $0.data.first else {
          throw HelixError.noDataInResponse
        }

        return user
      })
  }
}
