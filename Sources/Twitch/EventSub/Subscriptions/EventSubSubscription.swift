public struct EventSubSubscription<EventNotification: Event>: Sendable {
  let type: String
  let version: String
  let condition: [String: String]
}
