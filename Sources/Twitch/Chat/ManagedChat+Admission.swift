import Foundation

extension ManagedChat {
  struct SendAttempt: Sendable {
    let channelID: String
    let senderID: String
    let revision: UInt64
  }

  func checkSendAdmission(_ attempt: SendAttempt) throws {
    try checkCredentialRevision(attempt.revision)
    let history = sendLimiter.snapshot(for: attempt.senderID)
    if let block = sendBlock(in: attempt.channelID, history: history, now: .now, wallTime: Date()) {
      throw block
    }
  }

  /// Runs immediately before dispatch. Credential checks and booking have no suspension
  /// point, and a retired IRC transport cannot commit an attempt.
  func commitSend(_ attempt: SendAttempt, on transport: IRCConnectionLifetime? = nil) throws {
    try checkCredentialRevision(attempt.revision)
    let id = attempt.channelID
    let privileged = effectiveChatPrivilege(id).isPrivileged
    let interval = chatSendInterval(in: id)
    let commit = {
      self.sendLimiter.commit(
        account: attempt.senderID, channel: id, privileged: privileged, interval: interval,
        enforcesLimits: self.configuration.sending.enforcesLimits)
    }
    let limit = if let transport { try transport.commit(commit) } else { commit() }
    if let limit { throw ChatSendBlock(limit, now: .now, wallTime: Date()) }
  }

  func sendRestriction(
    in id: String, now: ContinuousClock.Instant
  ) -> ChatSendBlock? {
    guard !isShutdown else {
      return ChatSendBlock(eligibility: .unavailable("Managed chat is shut down."))
    }
    guard credentials?.user != nil else {
      return ChatSendBlock(eligibility: .unavailable("A user access token is required."))
    }
    return senderEvidence[.id(id)]?.restriction.block(at: now)
  }

  func sendBlock(
    in id: String, history: ChatSendLimiter.Snapshot?, now: ContinuousClock.Instant, wallTime: Date
  ) -> ChatSendBlock? {
    guard configuration.sending.enforcesLimits, let history,
      let limit = ChatSendLimiter.limit(
        history, channel: id, privileged: effectiveChatPrivilege(id).isPrivileged,
        interval: chatSendInterval(in: id), now: now)
    else { return nil }
    return ChatSendBlock(limit, now: now, wallTime: wallTime)
  }

  private func chatSendInterval(in id: String) -> Duration {
    max(
      configuration.sending.ordinaryChannelInterval,
      memberships[id]?.settings.slowMode ?? .zero)
  }
}

internal struct ChatSendBlock: Error {
  let eligibility: ChatSendEligibility
  let deadline: ContinuousClock.Instant?

  init(eligibility: ChatSendEligibility, deadline: ContinuousClock.Instant? = nil) {
    self.eligibility = eligibility
    self.deadline = deadline
  }

  init(_ limit: ChatSendLimiter.Limit, now: ContinuousClock.Instant, wallTime: Date) {
    self.init(
      eligibility: limit.eligibility(now: now, wallTime: wallTime), deadline: limit.deadline)
  }

  func delay(until waitDeadline: ContinuousClock.Instant?) throws -> Duration {
    guard case .channelCooldown = eligibility,
      let deadline, let waitDeadline, deadline <= waitDeadline
    else {
      throw ChatSendError.refused(eligibility)
    }
    return max(.zero, ContinuousClock.now.duration(to: deadline))
  }
}

internal enum ChatSendRestriction {
  case none
  case banned
  case timedOut(until: Date?, deadline: ContinuousClock.Instant?)

  static func timeout(until: Date?) -> Self {
    .timedOut(
      until: until,
      deadline: until.map {
        ContinuousClock.now.advanced(by: .seconds($0.timeIntervalSinceNow))
      })
  }

  func block(at now: ContinuousClock.Instant) -> ChatSendBlock? {
    switch self {
    case .none: nil
    case .banned: .init(eligibility: .banned)
    case .timedOut(let until, let deadline):
      if let deadline, deadline <= now {
        nil
      } else {
        .init(eligibility: .timedOut(until: until), deadline: deadline)
      }
    }
  }
}
