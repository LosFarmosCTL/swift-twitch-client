import Foundation

internal actor EventSubClient {
  let network: NetworkSession
  let decoder: JSONDecoder
  let diagnostics: TwitchDiagnostics
  private(set) var credentials: TwitchCredentials?
  private(set) var revision: UInt64 = 0
  private(set) var isRetired = false
  var sessions = Sessions()

  var subscriptions: [ConflictKey: Subscription] = [:]
  var remoteSubscriptions: [String: Subscription] = [:]

  init(
    network: NetworkSession,
    decoder: JSONDecoder,
    credentials: TwitchCredentials?,
    diagnostics: TwitchDiagnostics = .init()
  ) {
    self.network = network
    self.decoder = decoder
    self.credentials = credentials
    self.diagnostics = diagnostics
  }

  func checkRevision(_ revision: UInt64) throws {
    try Task.checkCancellation()

    guard !isRetired, revision == self.revision else { throw CancellationError() }
  }

  func reset(using credentials: TwitchCredentials?, revision: UInt64) async {
    guard !isRetired, revision > self.revision else { return }

    let closing = beginTeardown()
    self.credentials = credentials
    self.revision = revision

    for task in closing { await task.value }
  }

  func retire() async {
    isRetired = true

    for task in beginTeardown() { await task.value }
  }

  private func beginTeardown() -> [Task<Void, Never>] {
    let closing = beginClosingSessions()

    for subscription in Array(subscriptions.values) { closeSubscription(subscription) }
    return closing
  }
}
