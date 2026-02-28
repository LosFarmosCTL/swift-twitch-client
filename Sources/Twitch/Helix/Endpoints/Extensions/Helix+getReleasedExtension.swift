import Foundation

extension HelixEndpoint {
  public static func getReleasedExtension(
    extensionID: String,
    version: String? = nil
  ) -> HelixEndpoint<Extension, Extension, HelixEndpointResponseTypes.Normal> {
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
