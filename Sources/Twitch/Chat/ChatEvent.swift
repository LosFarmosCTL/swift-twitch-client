public enum ChatEvent {
  case message((ChatMessage) -> Void)
  case userstate((Userstate) -> Void)
  case timeoutOrBan((TimeoutOrBan) -> Void)
  case deletedMessage((DeletedMessage) -> Void)
  case announcement((Announcement) -> Void)
  case sub((Sub) -> Void)
  case raid((Raid) -> Void)
  case whisper((Whisper) -> Void)

  case ROOMSTATE((ROOMSTATE) -> Void)
  case NOTICE((NOTICE) -> Void)
}
