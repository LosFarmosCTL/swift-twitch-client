internal enum EventSubPayload {
  case welcome(EventSubWelcome)
  case keepalive
  case notification(EventSubNotification)
  case reconnect(EventSubReconnect)
  case revocation(EventSubRevocation)
}
