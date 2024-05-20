import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

internal class EventSubClient {
  private static let maxSubscriptionsPerConnection = 300

  internal var connections = [EventSubConnection]()

  internal let credentials: TwitchCredentials
  internal let urlSession: URLSession

  internal init(credentials: TwitchCredentials, urlSession: URLSession) {
    self.credentials = credentials
    self.urlSession = urlSession
  }

  internal func addHandler(handler: EventSubHandler) {
  }

  internal func getFreeWebsocketID() async throws -> String {
    // TODO:
    if connections.isEmpty {
      let connection = try await EventSubConnection(
        credentials: credentials, urlSession: urlSession)
      connections.append(connection)
    }

    return ""
  }
}

typealias EventID = String
