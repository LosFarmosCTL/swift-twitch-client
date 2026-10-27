# Helix reference fixtures

The following fixtures were copied from the corresponding operation’s **Example Response**
in https://dev.twitch.tv/docs/api/reference/ on 2026-10-27:

- `getCustomPowerUps` — Get Custom Power-up
- `getExtensionTransactions` — Get Extension Transactions
- `getSharedChatSession` — Get Shared Chat Session
- `getUserEmotes` — Get User Emotes
- `getPinnedChatMessage` — Get Pinned Chat Message
- `sendChatMessage` — Send Chat Message
- `createClipFromVOD` — Create Clip From VOD
- `getClipsDownload` — Get Clips Download
- `getUnbanRequests` — Get Unban Requests
- `resolveUnbanRequest` — Resolve Unban Requests
- `warnChatUser` — Warn Chat User
- `addSuspiciousStatusToChatUser` — Add Suspicious Status to Chat User
- `removeSuspiciousStatusFromChatUser` — Remove Suspicious Status From Chat User
- `getChannelStreamSchedule` — Get Channel Stream Schedule
- `getAuthorizationByUser` — Get Authorization By User

Only formatting and editorial JSON errors were normalized: omitted ellipses, replaced
smart quotation marks in the shared-chat example, and quoted the `data` key in the
remove-suspicious-status example. No response fields were added to make decoding pass.
