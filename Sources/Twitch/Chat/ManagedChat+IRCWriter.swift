import Foundation
import TwitchIRC

extension ManagedChat {
  struct IRCWriter {
    let id: UUID
    let supervisor: IRCConnectionSupervisor
    let task: Task<Void, Never>
  }

  nonisolated(nonsending) func sendIRC(_ message: OutgoingMessage) async throws {
    try Task.checkCancellation()
    guard !isShutdown else { throw ChatError.shutdown }
    guard configuration.writer == .irc else { throw IRCError.writerNotConfigured }

    let frame = try IRCWireMessage(message)
    let writer = try await ensureChatIRCWriter()
    try await writer.send(frame)
  }

  nonisolated(nonsending) func ensureChatIRCWriter() async throws -> IRCConnectionSupervisor {
    try Task.checkCancellation()
    _ = try credentials.requireUser()

    if case .failed = writerStatus {
      retireChatWriter()
    }

    let revision = credentialRevision
    let supervisor = writer?.supervisor ?? startIRCWriter()
    do {
      try await supervisor.waitUntilConnected()
    } catch {
      try checkCredentialRevision(revision)
      throw error
    }

    try checkCredentialRevision(revision)
    return supervisor
  }

  private func startIRCWriter() -> IRCConnectionSupervisor {
    let supervisor = IRCConnectionSupervisor(
      credentials: credentials, network: network, role: .write)
    let id = supervisor.id
    let task = Task { [weak client] in
      do {
        for try await update in try await supervisor.start() {
          await client?.withChat { $0.receiveIRC(update, role: .write, from: id) }
        }
      } catch {
        if !Task.isCancelled {
          await client?.withChat { $0.ircTransportFailed(error, role: .write, from: id) }
        }
      }
    }

    writer = IRCWriter(id: id, supervisor: supervisor, task: task)
    writerStatus = .connecting
    publishChatState()
    return supervisor
  }

  @discardableResult
  func retireChatWriter() -> Task<Void, Never>? {
    let retiring = writer
    retiring?.supervisor.invalidate()
    retiring?.task.cancel()
    writer = nil
    ircWriterState = nil
    writerStatus = .idle

    guard let retiring else { return nil }
    return Task { await retiring.supervisor.disconnect() }
  }
}
