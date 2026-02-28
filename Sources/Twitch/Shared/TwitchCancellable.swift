public struct TwitchCancellable: Sendable {
  private let onCancel: @Sendable () -> Void

  public init(_ onCancel: @escaping @Sendable () -> Void) {
    self.onCancel = onCancel
  }

  public func cancel() {
    onCancel()
  }
}
