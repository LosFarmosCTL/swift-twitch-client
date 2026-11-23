import Foundation

extension ManagedChat {
  var snapshot: ChatState { snapshot(with: chatEligibilitySnapshot().channels) }

  private func snapshot(with eligibility: [String: ChatSendEligibility]) -> ChatState {
    let channels = memberships.mapValues { member in
      ChatChannelState(
        channel: member.channel, status: member.status, settings: member.settings,
        privilege: effectiveChatPrivilege(member.channel.id), moderation: member.moderation,
        moderationRevocation: member.moderationRevocation,
        sending: eligibility[member.channel.id] ?? .eligible)
    }
    let effectiveWriterStatus: ChatComponentStatus =
      credentials?.user == nil
      ? .unavailable("A user access token is required.")
      : writerStatus
    return ChatState(
      credentialRevision: credentialRevision, userID: credentials?.userID,
      credentialChange: credentialChange,
      reader: configuration.reader == .eventSub ? eventSubReaderStatus : readerStatus,
      writer: effectiveWriterStatus,
      ircReader: ircReaderState, ircWriter: ircWriterState,
      channels: channels, lastDeparture: lastDeparture, sendEligibility: eligibility,
      isShutdown: isShutdown)
  }

  func messageStream(
    bufferingPolicy: AsyncStream<ChatEvent>.Continuation.BufferingPolicy
  ) -> AsyncStream<ChatEvent> {
    messageObservers.stream(bufferingPolicy: bufferingPolicy, finished: isShutdown) {
      [weak client] id in
      Task { await client?.withChat { $0.messageObservers.remove(id) } }
    }
  }

  func ircMessageStream(
    bufferingPolicy: AsyncStream<IRCMessage>.Continuation.BufferingPolicy
  ) -> AsyncStream<IRCMessage> {
    ircObservers.stream(bufferingPolicy: bufferingPolicy, finished: isShutdown) {
      [weak client] id in
      Task { await client?.withChat { $0.ircObservers.remove(id) } }
    }
  }

  func chatStateUpdates() -> AsyncStream<ChatState> {
    observeSendHistory()
    let initial = makeStateUpdate(scheduleRefresh: !isShutdown)

    return stateObservers.stream(
      bufferingPolicy: .bufferingNewest(1), initial: initial, finished: isShutdown
    ) { [weak client] id in
      Task {
        await client?.withChat { chat in
          chat.stateObservers.remove(id)
          if !chat.stateObservers.hasObservers {
            chat.sendHistoryObserver?.cancel()
            chat.sendHistoryObserver = nil
            chat.cancelEligibilityRefresh()
          }
        }
      }
    }
  }

  @discardableResult
  func publishChatState() -> ChatState {
    let state = makeStateUpdate(scheduleRefresh: !isShutdown && stateObservers.hasObservers)
    stateObservers.yield(state)
    return state
  }

  private func makeStateUpdate(scheduleRefresh: Bool) -> ChatState {
    let (eligibility, nextChange) = chatEligibilitySnapshot()
    if scheduleRefresh { scheduleChatEligibilityRefresh(at: nextChange) }
    return snapshot(with: eligibility)
  }

  func emitChat(_ event: ChatEvent) { messageObservers.yield(event) }

  func finishObservers() {
    stateObservers.finish()
    messageObservers.finish()
    ircObservers.finish()
    #if canImport(Combine)
      ircPublishers.finish()
    #endif
  }
}
