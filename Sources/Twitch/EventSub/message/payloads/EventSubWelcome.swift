import Foundation

internal struct EventSubWelcome: Decodable {
  let sessionID: String
  let keepaliveTimeout: Duration
  let connectedAt: Date

  internal struct Session: Decodable {
    let id: String
    let keepaliveTimeoutSeconds: Int

    let connectedAt: Date
  }

  enum CodingKeys: CodingKey {
    case session
  }

  internal init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let session = try container.decode(Session.self, forKey: .session)

    self.sessionID = session.id
    self.keepaliveTimeout = .seconds(session.keepaliveTimeoutSeconds)
    self.connectedAt = session.connectedAt
  }
}
