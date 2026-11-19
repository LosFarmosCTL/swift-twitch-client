import Foundation

extension EventSubClient {
  func receiveSocket(
    _ update: EventSubConnection.Update, in sessionID: UUID, from socketID: UUID
  ) {
    guard let session = sessions.active[sessionID] else { return }

    let isCurrent = session.connection.id == socketID
    guard isCurrent || session.drainingConnections[socketID] != nil else { return }

    // Outgoing sockets can still deliver frames during handoff. The replacement
    // determines whether the session survives from the moment it starts connecting.
    let controlsSession = isCurrent && session.replacement == nil

    switch update {
    case .notification(let frame):
      receive(.notification(frame), in: sessionID)
    case .revocation(let revocation):
      receive(.revocation(revocation), in: sessionID)
    case .reconnect(let url) where controlsSession:
      startHandoff(in: sessionID, at: url)
    case .failure(let error) where controlsSession:
      failSession(sessionID, error: error)
    case .reconnect, .failure:
      break
    }
  }

  private func startHandoff(in sessionID: UUID, at url: URL) {
    let replacement = makeSessionConnection(in: sessionID, at: url)
    let task = Task<Void, Never> { [weak self] in
      await self?.handoff(sessionID, to: replacement)
    }

    sessions.active[sessionID]?.replacement = SocketHandshake(connection: replacement, task: task)
  }

  private func handoff(_ sessionID: UUID, to replacement: EventSubConnection) async {
    do {
      let twitchSessionID = try await replacement.connect()
      guard
        let previous = sessions.active[sessionID]?.installReplacement(
          replacement, twitchSessionID: twitchSessionID)
      else { return }

      try await replacement.startReceiving()
      serveSlotWaiters()

      await previous.cancelAfterDraining()
      sessions.active[sessionID]?.drainingConnections[previous.id] = nil
    } catch {
      guard sessions.active[sessionID] != nil else { return }
      failSession(sessionID, error: .disconnected(with: error))
    }
  }
}

extension EventSubClient.Session {
  fileprivate mutating func installReplacement(
    _ replacement: EventSubConnection, twitchSessionID: String
  ) -> EventSubConnection {
    let previous = connection
    drainingConnections[previous.id] = previous

    connection = replacement
    self.twitchSessionID = twitchSessionID
    self.replacement = nil

    return previous
  }
}
