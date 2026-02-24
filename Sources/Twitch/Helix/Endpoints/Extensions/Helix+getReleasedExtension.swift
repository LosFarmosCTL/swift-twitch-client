import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == Extension, HelixResponseType == Extension
{
  public static func getReleasedExtension(
    extensionID: String,
    version: String? = nil
  ) -> Self {
    .init(
      method: "GET", path: "extensions/released",
      queryItems: { _ in
        [
          ("extension_id", extensionID),
          ("extension_version", version),
        ]
      },
      makeResponse: { response in
        guard let extensionInfo = response.data.first else {
          throw HelixError.noDataInResponse(responseData: response.rawData)
        }

        return extensionInfo
      })
  }
}
