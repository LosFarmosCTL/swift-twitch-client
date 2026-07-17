import Foundation
import Testing

@testable import Twitch

struct StreamsTests {
  private let harness = HelixTestHarness()

  @Test
  func getStreams() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/streams?first=1"))

    await harness.session.stub(
      url: url,
      body: MockedData.getStreamsJSON)

    let (streams, cursor) = try await harness.twitch.helix(
      endpoint: .getStreams(limit: 1))

    #expect(cursor == nil)

    #expect(streams.count == 1)
    #expect(streams.contains(where: { $0.id == "40952121085" }))
  }

  @Test
  func getFollowedStreams() async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/streams/followed?user_id=1234&first=1"))

    await harness.session.stub(
      url: url,
      body: MockedData.getFollowedStreamsJSON)

    let (streams, cursor) = try await harness.twitch.helix(
      endpoint: .getFollowedStreams(limit: 1))

    #expect(cursor == "eyJiIjp7IkN1cnNvciI6ImV5SnpJam8zT0RNMk5TNDBORFF4")

    #expect(streams.count == 1)
    #expect(streams.contains(where: { $0.id == "42170724654" }))
  }

  @Test
  func getStreamKey() async throws {
    let url = try #require(
      URL(string: "https://api.twitch.tv/helix/streams/key?broadcaster_id=1234"))

    await harness.session.stub(
      url: url,
      body: MockedData.getStreamKeyJSON)

    let key = try await harness.twitch.helix(endpoint: .getStreamKey())

    #expect(key == "live_44322889_a34ub37c8ajv98a0")
  }

  @Test
  func createStreamMarker() async throws {
    let url = try #require(URL(string: "https://api.twitch.tv/helix/streams/markers"))

    await harness.session.stub(
      url: url,
      method: "POST",
      body: MockedData.createStreamMarkerJSON)

    let marker = try await harness.twitch.helix(
      endpoint: .createStreamMarker(description: "hello, this is a marker!"))

    #expect(marker.id == "123")
    #expect(marker.positionSeconds == 244)
    #expect(marker.description == "hello, this is a marker!")
    #expect(marker.createdAt.formatted(.iso8601) == "2018-08-20T20:10:03Z")
  }

  @Test
  func getStreamMarkers() async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/streams/markers?user_id=1234&first=1"))

    await harness.session.stub(
      url: url,
      body: MockedData.getStreamMarkersJSON)

    let (markers, cursor) = try await harness.twitch.helix(
      endpoint: .getStreamMarkers(userID: "1234", limit: 1))

    #expect(cursor == "eyJiIjpudWxsLCJhIjoiMjk1MjA0Mzk3OjI1Mzpib29rbWFyazoxMDZiOGQ1Y")

    #expect(markers.count == 1)
    #expect(markers.first?.userID == "1234")
    #expect(markers.first?.userLogin == "user")

    let video = try #require(markers.first?.videos.first)
    #expect(video.videoID == "456")

    let marker = try #require(video.markers.first)
    #expect(marker.id == "106b8d6243a4f883d25ad75e6cdffdc4")
    #expect(marker.positionSeconds == 244)
    #expect(marker.description == "hello, this is a marker!")
    #expect(marker.url == "https://twitch.tv/user/manager/highlighter/456?t=0h4m06s")
  }
}
