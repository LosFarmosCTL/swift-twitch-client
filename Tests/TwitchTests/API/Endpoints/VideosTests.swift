import Foundation
import Testing

@testable import Twitch

struct VideosTests {
  private let harness = HelixTestHarness()

  @Test
  func getVideos() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/videos?id=987654321"))

    await harness.session.stub(
      url: url,
      body: MockedData.getVideosJSON)

    let (videos, cursor) = try await harness.twitch.helix(
      endpoint: .getVideos(ids: ["987654321"]))

    #expect(cursor == nil)

    #expect(videos.count == 1)

    let video = try #require(videos.first)
    #expect(video.id == "987654321")
    #expect(video.streamID == "111222333")
    #expect(video.userID == "56789")
    #expect(video.userLogin == "zzzztopper")
    #expect(video.userName == "zzzzTopper")
    #expect(video.title == "The incredible artistry that is me.")
    #expect(video.description == "")
    #expect(video.createdAt.formatted(.iso8601) == "2022-07-08T16:58:46Z")
    #expect(video.publishedAt.formatted(.iso8601) == "2022-07-08T16:58:46Z")
    #expect(video.url == "https://www.twitch.tv/videos/987654321")
    #expect(
      video.thumbnailURL
        == "https://static-cdn.jtvnw.net/cf_vods/dgeft87wbj63p/ce4ddf3095472cde00cd_zzzztopper_45725106652_1657299521//thumb/thumb0-%{width}x%{height}.jpg"
    )
    #expect(video.viewable == "public")
    #expect(video.viewCount == 395_246)
    #expect(video.language == "en")
    #expect(video.type == .archive)
    #expect(video.duration == "6h26m14s")
    #expect(video.mutedSegments == nil)
  }

  @Test
  func deleteVideos() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/videos?id=1535513785"))
    await harness.session.stub(
      url: url,
      method: "DELETE",
      body: MockedData.deleteVideosJSON)

    let deletedIDs = try await harness.twitch.helix(
      endpoint: .deleteVideos(ids: ["1535513785"]))

    #expect(deletedIDs == ["1535513785"])
  }
}
