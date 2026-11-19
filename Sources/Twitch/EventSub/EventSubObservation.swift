import Foundation

internal struct EventSubObservation: Sendable {
  let key: EventSubClient.ConflictKey
  let id: UUID
  weak var client: EventSubClient?

  func cancel() {
    Task { await client?.removeObservation(self) }
  }
}
