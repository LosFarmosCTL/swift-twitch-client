import Foundation
import Testing

@testable import Twitch

struct ClipsTests {
  private let harness = HelixTestHarness()

  @Test
  func createClipFromVOD() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/videos/clips?broadcaster_id=141981764&editor_id=1234&vod_id=2277656159&vod_offset=434&title=Standard%20Output&duration=12.5"
      ))

    await harness.session.stub(
      url: url, method: "POST", status: 202, body: MockedData.createClipFromVODJSON)

    let clip = try await harness.twitch.helix(
      for: .createClipFromVOD(
        "2277656159", broadcasterID: "141981764", vodOffset: 434,
        title: "Standard Output", duration: 12.5))

    #expect(clip.id == "FiveWordsForClipSlug")
    #expect(clip.editURL == "https://www.twitch.tv/twitchdev/clip/FiveWordsForClipSlug")
  }

  @Test
  func getClipsDownload() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/clips/downloads?broadcaster_id=141981764&editor_id=1234&clip_id=InexpensiveDistinctFoxChefFrank&clip_id=SpinelessCloudyLeopardMcaT"
      ))

    await harness.session.stub(url: url, body: MockedData.getClipsDownloadJSON)

    let clips = try await harness.twitch.helix(
      for: .getClipsDownload(
        ["InexpensiveDistinctFoxChefFrank", "SpinelessCloudyLeopardMcaT"],
        broadcasterID: "141981764"))

    #expect(clips.count == 2)
    #expect(clips.first?.clipID == "InexpensiveDistinctFoxChefFrank")
    #expect(
      clips.first?.landscapeDownloadURL
        == "https://production.assets.clips.twitchcdn.net/yFZG...")
    #expect(clips.first?.portraitDownloadURL == nil)
  }

  @Test
  func createClip() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/clips?broadcaster_id=1234"))

    await harness.session.stub(
      url: url,
      method: "POST",
      status: 202,
      body: MockedData.createClipJSON)

    let clip = try await harness.twitch.helix(for: .createClip())

    #expect(clip.id == "FiveWordsForClipSlug")
    #expect(clip.editURL == "https://www.twitch.tv/twitchdev/clip/FiveWordsForClipSlug")
  }

  @Test
  func getClips() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/clips?id=AwkwardHelplessSalamanderSwiftRage"))

    await harness.session.stub(
      url: url,
      body: MockedData.getClipsJSON)

    let (clips, cursor) = try await harness.twitch.helix(
      for: .getClips(clipIDs: ["AwkwardHelplessSalamanderSwiftRage"]))

    #expect(cursor == nil)
    #expect(clips.count == 1)

    let clip = clips.first
    #expect(clip?.id == "AwkwardHelplessSalamanderSwiftRage")
    #expect(clip?.broadcasterID == "67955580")
    #expect(clip?.creatorID == "53834192")
    #expect(clip?.viewCount == 10)
    #expect(clip?.createdAt.formatted(.iso8601) == "2017-11-30T22:34:18Z")
    #expect(
      clip?.thumbnailURL
        == "https://clips-media-assets.twitch.tv/157589949-preview-480x272.jpg")
    #expect(clip?.duration == 60)
    #expect(clip?.vodOffset == 480)
    #expect(clip?.isFeatured == false)
  }
}
