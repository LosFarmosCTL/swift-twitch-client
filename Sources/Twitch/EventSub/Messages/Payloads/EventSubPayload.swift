internal enum EventSubPayload {
  case welcome(EventSubWelcome)
  case keepalive
  case notification(EventSubNotificationFrame)
  case reconnect(EventSubReconnect)
  case revocation(EventSubRevocation)
}
