internal actor KeepaliveTimer {
  private var task: Task<Void, any Error>
  private var duration: Duration

  private let onTimeout: () -> Void

  init(duration: Duration = .seconds(10), onTimeout: @escaping () -> Void) {
    self.duration = duration
    self.onTimeout = onTimeout

    self.task = Task {
      try await Task.sleep(for: duration)
    }
  }

  func reset(duration: Duration? = nil) {
    if let duration {
      self.duration = duration
    }

    self.task.cancel()

    self.task = Task {
      try await Task.sleep(for: self.duration)

      self.onTimeout()
    }
  }
}
