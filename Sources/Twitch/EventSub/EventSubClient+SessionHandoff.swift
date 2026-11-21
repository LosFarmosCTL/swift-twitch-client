import Foundation

extension EventSubClient {
  func receiveSocket(
    _ update: EventSubConnection.Update, in sessionID: UUID, from socketID: UUID
  ) {
    guard let session = sessions.active[sessionID] else { return }

    let isCurrent = session.connection.id == socketID
    guard isCurrent || session.drainingConnections[socketID] != nil else { return }

    // The old socket can deliver frames while the replacement is connecting.
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

  private func startHandoff(
    in sessionID: UUID, at url: URL,
    deadline: ContinuousClock.Instant = .now.advanced(by: .seconds(30)),
    delay: Duration = .zero
  ) {
    let replacement = makeSessionConnection(in: sessionID, at: url)
    let task = Task<Void, Never> { [weak self] in
      if delay > .zero {
        do { try await Task.sleep(for: delay) } catch { return }
      }
      await self?.handoff(sessionID, to: replacement, at: url, deadline: deadline)
    }

    sessions.active[sessionID]?.replacement = SocketHandshake(connection: replacement, task: task)
  }

  private func handoff(
    _ sessionID: UUID, to replacement: EventSubConnection, at url: URL,
    deadline: ContinuousClock.Instant
  ) async {
    guard sessions.active[sessionID]?.replacement?.connection.id == replacement.id else { return }

    do {
      guard ContinuousClock.now < deadline else { throw EventSubError.timedOut }
      let twitchSessionID = try await replacement.connect(handshakeDeadline: deadline)
      guard sessions.active[sessionID]?.replacement?.connection.id == replacement.id,
        let previous = sessions.active[sessionID]?.installReplacement(
          replacement, twitchSessionID: twitchSessionID)
      else { return }

      try await replacement.startReceiving()
      serveSlotWaiters()

      await previous.cancelAfterDraining()
      sessions.active[sessionID]?.drainingConnections[previous.id] = nil
    } catch {
      guard let session = sessions.active[sessionID] else { return }
      let remaining = ContinuousClock.now.duration(to: deadline)
      if session.replacement?.connection.id == replacement.id, remaining > .zero {
        // No Welcome: the old connection may still be delivering notifications.
        startHandoff(in: sessionID, at: url, deadline: deadline, delay: min(.seconds(1), remaining))
      } else if session.connection.id == replacement.id
        || session.replacement?.connection.id == replacement.id
      {
        failSession(sessionID, error: error as? EventSubError ?? .disconnected(with: error))
      }
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
