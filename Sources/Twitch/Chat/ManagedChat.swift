import Foundation

/// Chat state is confined to its owning TwitchClient actor.
internal final class ManagedChat {
  let configuration: ChatConfiguration
  let network: NetworkSession
  let diagnostics: TwitchDiagnostics
  let sendLimiter = ChatSendLimiter.shared

  weak var client: TwitchClient?
  private(set) var credentials: TwitchCredentials
  private(set) var credentialChange: ChatCredentialChange?
  private var shutdownTask: Task<Void, Never>?

  var credentialRevision: UInt64 { credentialChange?.revision ?? 0 }
  var isShutdown: Bool { shutdownTask != nil }

  // MARK: - Membership and identity

  var memberships: [String: Membership] = [:]
  var lastDeparture: ChatDeparture?

  var knownChannels: [ChatChannelReference: ChatChannel] = [:]
  var lookups: [ChatChannelReference: ChannelLookup] = [:]
  var membershipIntent: UInt64 = 0
  var pendingJoins: [UInt64: PendingJoin] = [:]
  var latestPartIntents: [ChatChannelReference: UInt64] = [:]

  // MARK: - IRC transports

  var reader: IRCReader?
  var readerRetryLogins: Set<String> = []
  var writer: IRCWriter?
  var ircReaderState: IRCState?
  var ircWriterState: IRCState?
  var readerStatus: ChatComponentStatus = .idle
  var writerStatus: ChatComponentStatus = .idle

  // MARK: - Sender evidence and eligibility

  var prefill: Task<Void, Never>?
  var senderEvidence: [ChatChannelReference: SenderEvidence] = [:]
  var lastSendOutcomes: [String: ChatSendOutcome] = [:]
  var sendDestinations: Set<String> = []
  var sendHistoryObserver: Task<Void, Never>?
  var eligibilityRefresh: (deadline: ContinuousClock.Instant, task: Task<Void, Never>)?

  // MARK: - Observers

  var stateObservers = ChatStreams<ChatState>()
  var messageObservers = ChatStreams<ChatEvent>()
  var ircObservers = ChatStreams<IRCMessage>()

  #if canImport(Combine)
    let ircPublishers = IRCMessagePublishers()
  #endif

  // MARK: - Lifetime

  init(
    configuration: ChatConfiguration,
    credentials: TwitchCredentials,
    network: NetworkSession,
    diagnostics: TwitchDiagnostics
  ) {
    self.configuration = configuration
    self.credentials = credentials
    self.network = network
    self.diagnostics = diagnostics
  }

  deinit {
    _ = stopBackgroundWork()

    for member in memberships.values {
      member.endReadiness(throwing: ChatError.shutdown)
      member.stop()
    }

    finishObservers()
  }

  @discardableResult
  func shutdownChat() -> Task<Void, Never> {
    if let shutdownTask { return shutdownTask }

    for id in Array(memberships.keys) { endMembership(id, reason: .shutdown) }
    let closing = stopBackgroundWork()
    let shutdown = Task {
      for task in closing { await task.value }
    }

    shutdownTask = shutdown

    publishChatState()
    finishObservers()
    return shutdown
  }

  func checkCredentialRevision(_ revision: UInt64) throws {
    try Task.checkCancellation()
    guard revision == credentialRevision else { throw ChatError.credentialsChanged }
    guard !isShutdown else { throw ChatError.shutdown }
  }

  func switchCredentials(
    to credentials: TwitchCredentials, behavior: ChatCredentialSwitchBehavior
  ) {
    let preserveReader =
      behavior == .preserveChannels && configuration.reader == .irc(.anonymous) && reader != nil
    let change = ChatCredentialChange(
      revision: credentialRevision &+ 1, previousUserID: self.credentials.userID,
      userID: credentials.userID, behavior: behavior, anonymousReaderPreserved: preserveReader)
    self.credentials = credentials
    credentialChange = change
    if isShutdown { return }

    cancelLookups(throwing: .credentialsChanged)
    retireChatWriter()
    stopCredentialTasks()

    if change.previousUserID != change.userID {
      senderEvidence.removeAll()
      lastSendOutcomes.removeAll()
    }

    if !preserveReader { retireChatReader() }

    switch behavior {
    case .partChannels:
      for id in Array(memberships.keys) { endMembership(id, reason: .credentialsChanged) }
    case .preserveChannels:
      for member in memberships.values {
        member.prepareForCredentialChange(preserveReader: preserveReader)
      }
      for member in memberships.values {
        startMembership(member)
      }
    }

    if stateObservers.hasObservers { observeSendHistory() }
    if !memberships.isEmpty { startModerationPrefillIfNeeded() }
    publishChatState()
  }

  private func stopBackgroundWork() -> [Task<Void, Never>] {
    let closing = [retireChatReader(), retireChatWriter()].compactMap { $0 }
    cancelLookups(throwing: .shutdown)
    stopCredentialTasks()
    eligibilityRefresh?.task.cancel()
    eligibilityRefresh = nil
    return closing
  }

  private func stopCredentialTasks() {
    prefill?.cancel()
    prefill = nil
    sendHistoryObserver?.cancel()
    sendHistoryObserver = nil
  }
}
