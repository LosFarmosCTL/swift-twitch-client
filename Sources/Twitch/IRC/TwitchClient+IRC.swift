extension TwitchClient {
  /// Creates an unconnected, independently owned IRC session.
  /// Credentials are captured now. Later switchCredentials calls do not update this session.
  public func makeIRCClient(
    mode: TwitchIRCClient.Mode = .readWrite
  ) -> TwitchIRCClient {
    TwitchIRCClient(
      .authenticated(self.authentication), mode: mode, network: self.network)
  }
}
