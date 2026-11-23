import Foundation

extension ManagedChat {
  final class Membership {
    let channel: ChatChannel
    let generation = UUID()
    var joinIntent: UInt64

    private(set) var status: ChatComponentStatus = .connecting
    private var setupError: (any Error)?
    private(set) var readinessWaiters: [UUID: AsyncThrowingStream<Void, any Error>.Continuation] =
      [:]

    var settings = ChatRoomSettings()
    var roomSettingFields: Set<ChatIRCSetting> = []
    var settingsTask: Task<Void, Never>?
    var eventSub: Task<Void, Never>?
    var moderation: ChatComponentStatus = .idle
    var moderationRevocation: EventSubRevocation.Status?
    var moderationTask: (generation: UUID, task: Task<Void, Never>)?
    var moderationBlocked = false
    var deletedMessageIDs = RecentIDs<String>(capacity: 4096)

    init(channel: ChatChannel, joinIntent: UInt64) {
      self.channel = channel
      self.joinIntent = joinIntent
    }

    nonisolated(nonsending) func waitUntilReady() async throws {
      try Task.checkCancellation()

      if status == .ready { return }
      if let setupError { throw setupError }

      let id = UUID()
      let (stream, reply) = AsyncThrowingStream<Void, any Error>.makeStream()
      readinessWaiters[id] = reply
      defer { readinessWaiters[id] = nil }

      for try await _ in stream {}
      try Task.checkCancellation()
    }

    func updateStatus(_ status: ChatComponentStatus, error: (any Error)? = nil) {
      self.status = status
      switch status {
      case .ready:
        setupError = nil
        endReadiness()
      case .failed(let message), .unavailable(let message):
        let failure = error ?? ChatError.setupFailed(message)
        setupError = failure
        endReadiness(throwing: failure)
      default:
        setupError = nil
      }
    }

    func endReadiness(throwing error: (any Error)? = nil) {
      for reply in readinessWaiters.values { reply.finish(throwing: error) }
      readinessWaiters.removeAll()
    }

    func stopModeration(unavailable reason: String? = nil) {
      moderationTask?.task.cancel()
      moderationTask = nil
      moderation = reason.map(ChatComponentStatus.unavailable) ?? .idle
      moderationRevocation = nil
    }

    func stop() {
      eventSub?.cancel()
      eventSub = nil
      settingsTask?.cancel()
      settingsTask = nil
      stopModeration()
    }

    func prepareForCredentialChange(preserveReader: Bool) {
      endReadiness(throwing: ChatError.credentialsChanged)
      stop()
      moderationBlocked = false

      if !preserveReader {
        updateStatus(.reconnecting)
        settings.isKnown = false
        roomSettingFields.removeAll()
      }
    }
  }

  struct MembershipAttempt: Sendable {
    let channel: ChatChannel
    let generation: UUID
    let revision: UInt64

    var channelID: String { channel.id }
  }

  /// Orders concurrent unresolved join and part requests so an older lookup cannot
  /// override a newer part (even when join and part use opposite ID/login aliases).
  struct MembershipIntentTracker {
    struct PendingJoin {
      let reference: ChatChannelReference
      let lookupWaiter = UUID()
    }

    private var latestIntent: UInt64 = 0
    private var pendingJoins: [UInt64: PendingJoin] = [:]
    private var latestPartIntents: [ChatChannelReference: UInt64] = [:]

    mutating func nextIntent() -> UInt64 {
      latestIntent &+= 1
      return latestIntent
    }

    mutating func beginPendingJoin(reference: ChatChannelReference) -> (
      intent: UInt64, waiterID: UUID
    ) {
      let intent = nextIntent()
      let pending = PendingJoin(reference: reference)
      pendingJoins[intent] = pending
      return (intent, pending.lookupWaiter)
    }

    mutating func endPendingJoin(intent: UInt64) {
      pendingJoins[intent] = nil
      prunePartIntents()
    }

    func isJoinWithdrawn(
      channel: ChatChannel, reference: ChatChannelReference, intent: UInt64
    ) -> Bool {
      let references: [ChatChannelReference] = [
        .id(channel.id), .login(channel.login), reference,
      ]
      return references.contains { latestPartIntents[$0, default: 0] > intent }
    }

    mutating func recordPart(
      for references: [ChatChannelReference], intent: UInt64
    ) -> [(reference: ChatChannelReference, waiterID: UUID)] {
      for reference in references {
        latestPartIntents[reference] = max(latestPartIntents[reference, default: 0], intent)
      }

      let withdrawn = pendingJoins.compactMap { order, pending in
        order < intent && references.contains(pending.reference)
          ? (pending.reference, pending.lookupWaiter)
          : nil
      }
      prunePartIntents()
      return withdrawn
    }

    private mutating func prunePartIntents() {
      let earliestJoin = pendingJoins.keys.min() ?? latestIntent
      latestPartIntents = latestPartIntents.filter { $0.value > earliestJoin }
    }
  }

  func attempt(for member: Membership) -> MembershipAttempt {
    MembershipAttempt(
      channel: member.channel, generation: member.generation, revision: credentialRevision)
  }

  func isCurrent(_ attempt: MembershipAttempt) -> Bool {
    attempt.revision == credentialRevision
      && memberships[attempt.channelID]?.generation == attempt.generation
  }
}
