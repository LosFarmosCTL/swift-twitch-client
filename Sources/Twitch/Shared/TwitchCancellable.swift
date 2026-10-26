/// A value that invokes a cancellation action explicitly.
///
/// Call `cancel()` to request cancellation. Dropping this value does not invoke the
/// action. Copies share the same closure, and repeated cancellation calls invoke it
/// again.
public struct TwitchCancellable: Sendable {
  private let onCancel: @Sendable () -> Void

  /// Creates a handle that explicitly invokes a cancellation action.
  ///
  /// - Parameters:
  ///   - onCancel: The action to invoke each time `cancel()` is called.
  public init(_ onCancel: @escaping @Sendable () -> Void) {
    self.onCancel = onCancel
  }

  /// Invokes this handle’s cancellation action.
  ///
  /// Cancellation is cooperative and may schedule asynchronous cleanup. Each call invokes
  /// the stored action; this value does not guarantee that the action is idempotent.
  public func cancel() {
    onCancel()
  }
}
