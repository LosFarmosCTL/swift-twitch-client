import Foundation

public struct Raid {
  public let rawIRCTags: [String: String]
  public let rawIRCMessage: String

  public let systemMessage: String
  public let messageId: String

  public let channelName: String
  public let channelId: String

  public let senderUserId: String
  public let senderDisplayName: String
  public let senderLogin: String
  public let senderProfileImageUrl: String
  public let viewerCount: Int

  public let timestamp: Date

  internal init(from message: USERNOTICE) {
    self.rawIRCTags = message.rawIRCTags
    self.rawIRCMessage = message.rawIRCMessage

    self.systemMessage = message.systemMsg
    self.messageId = message.msgId

    self.channelName = message.channelName
    self.channelId = message.channelId

    self.senderUserId = message.userId
    self.senderDisplayName = message.displayName
    self.senderLogin = message.login
    self.senderProfileImageUrl = message.profileImageUrl
    self.viewerCount = message.viewerCount

    self.timestamp = message.timestamp
  }
}

/* Example message:
@badge-info=;
badges=;
color=;
display-name=LosFarmosCTL;
emotes=;
flags=;
id=6be90097-94e8-4405-ab4e-73e192981af7;
login=losfarmosctl;
mod=0;
msg-id=raid;
msg-param-displayName=LosFarmosCTL;
msg-param-login=losfarmosctl;
msg-param-profileImageURL=<URL>;
msg-param-viewerCount=420;
room-id=22484632;
subscriber=0;
system-msg=420\sraiders\sfrom\sLosFarmosCTL\shave\sjoined!;
tmi-sent-ts=1678385206807;
user-id=101676978;
user-type= :tmi.twitch.tv USERNOTICE #forsen
*/
