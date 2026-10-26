extension TwitchClient {
  /// Creates an unconnected, independently owned IRC session.
  ///
  /// Credentials are captured now. Later `switchCredentials(to:)` calls do not update
  /// this session. Configure desired channels and register observers before connecting.
  ///
  /// - Parameter mode: Whether to enable sending as well as receiving. Defaults to
  ///   `.readWrite`.
  /// - Returns: A new IRC client that has not started connecting.
  public func makeIRCClient(
    mode: TwitchIRCClient.Mode = .readWrite
  ) -> TwitchIRCClient {
    TwitchIRCClient(
      .authenticated(self.credentials), mode: mode, network: self.network)
  }
}
