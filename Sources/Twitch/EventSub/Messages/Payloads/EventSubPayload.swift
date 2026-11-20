internal enum EventSubPayload {
  case welcome(EventSubWelcome)
  case keepalive
  case notification(EventSubMessage.Subscription)
  case reconnect(EventSubReconnect)
  case revocation(EventSubRevocation)
}
