import Foundation
import TwitchIRC

extension ManagedChat {
  func receiveIRC(_ update: IRCConnectionUpdate, role: IRCRecovery.Role, from id: UUID) {
    guard id == (role == .read ? reader?.id : writer?.id) else { return }

    switch update {
    case .message(let message):
      emitChatIRCMessage(message, role: role)
    case .state(let state):
      if role == .read {
        updateIRCReaderState(state)
      } else {
        ircWriterState = state
        writerStatus = state.status.chatStatus
      }
      publishChatState()
    }
  }

  func ircTransportFailed(_ error: any Error, role: IRCRecovery.Role, from id: UUID) {
    guard id == (role == .read ? reader?.id : writer?.id) else { return }

    let failed = ChatComponentStatus.failed(String(describing: error))
    if role == .read {
      readerStatus = failed
      for member in memberships.values { member.updateStatus(failed, error: error) }
    } else {
      writerStatus = failed
    }
    publishChatState()
  }
}

extension IRCState.Status {
  var chatStatus: ChatComponentStatus {
    switch self {
    case .idle, .shutdown: .idle
    case .connecting: .connecting
    case .connected: .ready
    case .reconnecting: .reconnecting
    case .failed(let error): .failed(String(describing: error))
    }
  }
}
