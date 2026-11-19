import Foundation
import TwitchIRC

extension ManagedChat {
  nonisolated(nonsending) func sendMessage(
    _ text: String, to channel: ChatChannel, replyTo messageID: String? = nil,
    clientNonce: String? = nil, waitingForChannelCooldown maximumWait: Duration? = nil
  ) async throws -> ChatSendOutcome {
    try validateChatMessage(
      text, to: channel, replyTo: messageID, clientNonce: clientNonce)

    let sender = try credentials.requireUser()
    let attempt = SendAttempt(
      channelID: channel.id, senderID: sender.id, revision: credentialRevision)
    let deadline = maximumWait.map { ContinuousClock.now.advanced(by: max(.zero, $0)) }
    let frame = try prepareIRCMessage(
      text, to: channel, replyTo: messageID, clientNonce: clientNonce)

    cacheChatChannel(channel)
    sendDestinations.insert(channel.id)
    publishChatState()

    while true {
      do {
        try checkSendAdmission(attempt)
        let outcome: ChatSendOutcome
        if let frame {
          try await sendChatIRC(frame, attempt: attempt)
          outcome = .written(clientNonce: clientNonce)
        } else {
          outcome = try await sendChatHelix(text, replyTo: messageID, attempt: attempt)
        }
        recordChatSendOutcome(outcome, for: attempt)
        return outcome
      } catch let refusal as ChatSendBlock {
        try await Task.sleep(for: refusal.delay(until: deadline))
      } catch {
        recordChatSendOutcome(chatSendFailure(error), for: attempt)
        throw error
      }
    }
  }

  private func prepareIRCMessage(
    _ text: String, to channel: ChatChannel, replyTo messageID: String?, clientNonce: String?
  ) throws -> IRCWireMessage? {
    guard configuration.writer == .irc else { return nil }
    return try IRCWireMessage(
      .privateMessage(
        to: channel.login, message: text, messageIDToReply: messageID, clientNonce: clientNonce))
  }

  nonisolated(nonsending) private func sendChatIRC(
    _ frame: IRCWireMessage, attempt: SendAttempt
  ) async throws {
    let writer = try await ensureChatIRCWriter()
    try await writer.send(frame) { [weak client] permit in
      guard let client else { throw ChatError.shutdown }
      try await client.withChat { try $0.commitSend(attempt, on: permit) }
    }
  }

  private func validateChatMessage(
    _ text: String, to channel: ChatChannel, replyTo messageID: String?,
    clientNonce: String?
  ) throws {
    guard !isShutdown else { throw ChatError.shutdown }
    guard channel.isValidForManagedChat else { throw ChatError.invalidChannel }
    guard !text.isEmpty, text.count <= 500, IRCWireMessage.isSafeText(text),
      [messageID, clientNonce].compactMap({ $0 }).allSatisfy({
        !$0.isEmpty && !$0.contains("\0")
      })
    else { throw ChatSendError.invalidMessage }

    if configuration.writer == .helix, clientNonce != nil {
      throw ChatSendError.unsupportedClientNonce
    }
  }

  nonisolated(nonsending) private func sendChatHelix(
    _ text: String, replyTo messageID: String?, attempt: SendAttempt
  ) async throws -> ChatSendOutcome {
    let response = try await TwitchClient.helix(
      for: .sendChatMessage(in: attempt.channelID, message: text, replyTo: messageID),
      credentials: credentials, network: network,
      beforeDispatch: {
        try self.commitSend(attempt)
        self.writerStatus = .ready
        self.publishChatState()
      })
    guard response.value.isSent else {
      throw ChatSendError.rejected(
        code: response.value.dropReason?.code,
        message: response.value.dropReason?.message ?? "Twitch did not send the message.")
    }
    return .accepted(messageID: response.value.messageID)
  }

  private func recordChatSendOutcome(_ outcome: ChatSendOutcome, for attempt: SendAttempt) {
    guard attempt.revision == credentialRevision, !isShutdown else { return }
    lastSendOutcomes[attempt.channelID] = outcome
    publishChatState()
  }

  private func chatSendFailure(_ error: any Error) -> ChatSendOutcome {
    switch error {
    case ChatSendError.rejected(let code, let message):
      .rejected(code: code, message: message)
    case HelixError.rateLimited: .rateLimited
    default: .failed(String(describing: error))
    }
  }
}
