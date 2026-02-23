internal final actor KeepaliveTimer {
  private var task: Task<Void, Never>?
  private var duration: Duration

  private let onTimeout: @Sendable () async -> Void

  init(
    duration: Duration = .seconds(10),
    onTimeout: @escaping @Sendable () async -> Void
  ) {
    self.duration = duration
    self.onTimeout = onTimeout

    self.task = Self.makeTask(delay: duration, handler: onTimeout)
  }

  deinit {
    self.task?.cancel()
  }

  func reset(duration: Duration? = nil) {
    if let duration { self.duration = duration }

    self.task?.cancel()
    self.task = Self.makeTask(delay: self.duration, handler: self.onTimeout)
  }

  func cancel() {
    self.task?.cancel()
    self.task = nil
  }

  private nonisolated static func makeTask(
    delay: Duration,
    handler: @escaping @Sendable () async -> Void
  ) -> Task<Void, Never> {
    Task { [delay, handler] in
      do { try await Task.sleep(for: delay) } catch { return }
      if Task.isCancelled { return }
      await handler()
    }
  }
}
