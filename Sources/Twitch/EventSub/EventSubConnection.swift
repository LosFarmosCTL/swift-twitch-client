import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

internal actor EventSubConnection {
  private let eventsubURL: URL = URL(string: "wss://eventsub.wss.twitch.tv/ws")!

  private let credentials: TwitchCredentials
  private let urlSession: URLSession
  private let decoder: JSONDecoder

  private var websocket: URLSessionWebSocketTask?
  private var completionHandler: ((Result<EventSubNotification, EventSubError>) -> Void)?

  private var welcomeContinuation: CheckedContinuation<EventSubWelcome, any Error>?

  internal var socketID: String?

  init(credentials: TwitchCredentials, urlSession: URLSession, decoder: JSONDecoder) {
    self.credentials = credentials
    self.urlSession = urlSession
    self.decoder = decoder
  }

  deinit {
    self.websocket?.cancel(with: .goingAway, reason: nil)
  }

  internal func connect(
    completionHandler: @escaping (Result<EventSubNotification, EventSubError>) -> Void
  ) async throws -> String {
    guard self.websocket == nil else { throw WebSocketError.alreadyConnected }

    self.completionHandler = completionHandler

    let welcomeMessage = try await self.startWebsocket()
    self.socketID = welcomeMessage.sessionID
    return welcomeMessage.sessionID
  }

  private func startWebsocket() async throws -> EventSubWelcome {
    self.websocket = urlSession.webSocketTask(with: eventsubURL)
    self.websocket?.receive(completionHandler: receiveMessage)
    self.websocket?.resume()

    return try await waitForWelcomeMessage()
  }

  private func waitForWelcomeMessage() async throws -> EventSubWelcome {
    return try await withCheckedThrowingContinuation { continuation in
      self.welcomeContinuation = continuation
    }
  }

  private func receiveMessage(
    _ result: Result<URLSessionWebSocketTask.Message, any Error>
  ) {
    switch result {
    case .success(let message):
      switch message {
      case .string(let string):
        print(string)
        let message = try? parseMessage(string)

        guard let message else {
          welcomeContinuation?.resume(throwing: EventSubError.invalidWelcomeMessage)
          welcomeContinuation = nil
          break
        }

        handleMessage(message)
      case .data: fallthrough
      @unknown default: break
      }
    case .failure(let error):
      if let welcomeContinuation {
        welcomeContinuation.resume(throwing: error)
        self.welcomeContinuation = nil
      } else {
        completionHandler?(
          .failure(EventSubError.disconnected(with: error, socketID: socketID ?? "")))
      }
    }

    self.websocket?.receive(completionHandler: receiveMessage)
  }

  private func parseMessage(_ message: String) throws -> EventSubMessage {
    let data = Data(message.utf8)

    return try decoder.decode(EventSubMessage.self, from: data)
  }

  private func handleMessage(_ message: EventSubMessage) {
    switch message.payload {
    case .notification(let notification):
      completionHandler?(.success(notification))
    case .welcome(let welcome):
      welcomeContinuation?.resume(returning: welcome)
      welcomeContinuation = nil
    case .revocation(let revocation):
      completionHandler?(.failure(EventSubError.revocation(revocation)))
    case .reconnect: break
    case .keepalive: print("KEEPALIVE")
    }
  }
}
