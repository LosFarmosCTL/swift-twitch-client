import Foundation
import TwitchIRC

extension ManagedChat {
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

extension IRCChannelStatus {
  var chatStatus: ChatComponentStatus {
    switch self {
    case .joining: .connecting
    case .joined: .ready
    case .reconnecting: .reconnecting
    case .failed(let reason): .failed(String(describing: reason))
    }
  }
}
