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
    var eventSub: Task<Void, Never>?
    var moderation: ChatComponentStatus = .idle
    var moderationRevocation: EventSubRevocation.Status?
    var moderationTask: (generation: UUID, task: Task<Void, Never>)?
    var moderationBlocked = false
    var deletedMessageIDs = RecentIDs(capacity: 4096)

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

  func attempt(for member: Membership) -> MembershipAttempt {
    MembershipAttempt(
      channel: member.channel, generation: member.generation, revision: credentialRevision)
  }

  func isCurrent(_ attempt: MembershipAttempt) -> Bool {
    attempt.revision == credentialRevision
      && memberships[attempt.channelID]?.generation == attempt.generation
  }
}
