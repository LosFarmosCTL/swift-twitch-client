import Foundation

extension ManagedChat {
  func sendEligibility(in channelID: String) -> ChatSendEligibility {
    sendDestinations.insert(channelID)
    return publishChatState().sendEligibility[channelID] ?? .eligible
  }

  func observeSendHistory() {
    guard sendHistoryObserver == nil, let sender = credentials?.user, !isShutdown else { return }
    let revision = credentialRevision
    let updates = sendLimiter.updates(for: sender.id)
    sendHistoryObserver = Task { [weak client] in
      for await _ in updates {
        await client?.withChat { chat in
          guard chat.credentialRevision == revision, !chat.isShutdown else { return }
          chat.publishChatState()
        }
      }
    }
  }

  func chatEligibilitySnapshot() -> (
    channels: [String: ChatSendEligibility], deadline: ContinuousClock.Instant?
  ) {
    let destinations = sendDestinations.union(memberships.keys)
    guard !destinations.isEmpty else { return ([:], nil) }
    let history = credentials?.user.map { sendLimiter.snapshot(for: $0.id) }
    let now = ContinuousClock.now
    let wallTime = Date()
    var channels: [String: ChatSendEligibility] = [:]
    var next: ContinuousClock.Instant?
    for id in destinations {
      let block =
        sendRestriction(in: id, now: now)
        ?? sendBlock(in: id, history: history, now: now, wallTime: wallTime)
      channels[id] = block?.eligibility ?? .eligible
      if let deadline = block?.deadline { next = min(next ?? deadline, deadline) }
    }
    return (channels, next)
  }

  func scheduleChatEligibilityRefresh(at deadline: ContinuousClock.Instant?) {
    guard deadline != eligibilityRefresh?.deadline else { return }
    eligibilityRefresh?.task.cancel()
    eligibilityRefresh = deadline.map { deadline in
      let task = Task { [weak client] in
        do {
          try await ContinuousClock().sleep(until: deadline)
          await client?.withChat { $0.refreshChatEligibility(at: deadline) }
        } catch {}
      }
      return (deadline, task)
    }
  }

  private func refreshChatEligibility(at deadline: ContinuousClock.Instant) {
    guard eligibilityRefresh?.deadline == deadline, !Task.isCancelled else { return }
    eligibilityRefresh = nil
    publishChatState()
  }
}
