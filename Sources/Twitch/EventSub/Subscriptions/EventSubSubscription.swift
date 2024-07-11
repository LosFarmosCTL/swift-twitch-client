public struct EventSubSubscription<EventNotification: Event> {
  let type: String
  let version: String
  let condition: [String: String]
}
