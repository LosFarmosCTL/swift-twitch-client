public enum ChatEvent {
  case message(() -> Void)
  case userstate(() -> Void)
  case timeoutOrBan(() -> Void)
  case deletedMessage(() -> Void)
  case announcement(() -> Void)
  case sub(() -> Void)
  case raid(() -> Void)
  case whisper(() -> Void)

  case ROOMSTATE(() -> Void)
  case NOTICE(() -> Void)
}
