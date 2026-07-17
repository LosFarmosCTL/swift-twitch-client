import Foundation
import Testing

@testable import Twitch

struct ScheduleTests {
  private let harness = HelixTestHarness()

  @Test
  func getChanneliCalendar() async throws {
    let url = try #require(
      URL(
        string: "https://api.twitch.tv/helix/schedule/icalendar?broadcaster_id=141981764")
    )

    await harness.session.stub(
      url: url,
      body: MockedData.getChanneliCalendarICS)

    let calendar = try await harness.twitch.helix(
      endpoint: .getChanneliCalendar(broadcasterID: "141981764")
    )

    #expect(calendar.contains("BEGIN:VCALENDAR"))
    #expect(calendar.contains("NAME:TwitchDev"))
    #expect(calendar.contains("SUMMARY:TwitchDev Monthly Update // July 1, 2021"))
  }

  @Test
  func updateChannelStreamSchedule() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/schedule/settings?broadcaster_id=1234&is_vacation_enabled=true&vacation_start_time=2021-05-16T00:00:00Z&vacation_end_time=2021-05-23T00:00:00Z&timezone=America/New_York"
      ))

    await harness.session.stub(
      url: url,
      method: "PATCH",
      status: 204)

    let startTime = try Date("2021-05-16T00:00:00Z", strategy: .iso8601)
    let endTime = try Date("2021-05-23T00:00:00Z", strategy: .iso8601)

    try await harness.twitch.helix(
      endpoint: .updateChannelStreamSchedule(
        isVacationEnabled: true,
        vacationStartTime: startTime,
        vacationEndTime: endTime,
        timezone: "America/New_York"
      ))
  }

  @Test
  func createChannelStreamScheduleSegment() async throws {
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/schedule/segment?broadcaster_id=1234"))

    await harness.session.stub(
      url: url,
      method: "POST",
      body: MockedData.createChannelStreamScheduleSegmentJSON)

    let startTime = try Date("2021-07-01T18:00:00Z", strategy: .iso8601)

    let schedule = try await harness.twitch.helix(
      endpoint: .createChannelStreamScheduleSegment(
        startTime: startTime,
        timezone: "America/New_York",
        duration: 60,
        isRecurring: false,
        categoryID: "509670",
        title: "TwitchDev Monthly Update // July 1, 2021"
      ))

    #expect(schedule.broadcasterID == "141981764")
    #expect(schedule.broadcasterLogin == "twitchdev")
    #expect(schedule.vacation == nil)

    let segment = try #require(schedule.segments.first)
    #expect(
      segment.id
        == "eyJzZWdtZW50SUQiOiJlNGFjYzcyNC0zNzFmLTQwMmMtODFjYS0yM2FkYTc5NzU5ZDQiLCJpc29ZZWFyIjoyMDIxLCJpc29XZWVrIjoyNn0="
    )
    #expect(segment.title == "TwitchDev Monthly Update // July 1, 2021")
    #expect(segment.startTime.formatted(.iso8601) == "2021-07-01T18:00:00Z")
    #expect(segment.endTime.formatted(.iso8601) == "2021-07-01T19:00:00Z")
    #expect(segment.canceledUntil == nil)
    #expect(segment.category?.id == "509670")
    #expect(segment.category?.name == "Science & Technology")
    #expect(segment.isRecurring == false)
  }

  @Test
  func updateChannelStreamScheduleSegment() async throws {
    let segmentID =
      "eyJzZWdtZW50SUQiOiJlNGFjYzcyNC0zNzFmLTQwMmMtODFjYS0yM2FkYTc5NzU5ZDQiLCJpc29ZZWFyIjoyMDIxLCJpc29XZWVrIjoyNn0="
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/schedule/segment?broadcaster_id=1234&id=\(segmentID)"
      ))

    await harness.session.stub(
      url: url,
      method: "PATCH",
      body: MockedData.updateChannelStreamScheduleSegmentJSON)

    let schedule = try await harness.twitch.helix(
      endpoint: .updateChannelStreamScheduleSegment(
        segmentID: segmentID,
        duration: 120
      ))

    let segment = try #require(schedule.segments.first)
    #expect(segment.endTime.formatted(.iso8601) == "2021-07-01T20:00:00Z")
    #expect(segment.category?.name == "Science & Technology")
    #expect(segment.isRecurring == false)
  }

  @Test
  func deleteChannelStreamScheduleSegment() async throws {
    let segmentID =
      "eyJzZWdtZW50SUQiOiI4Y2EwN2E2NC0xYTZkLTRjYWItYWE5Ni0xNjIyYzNjYWUzZDkiLCJpc29ZZWFyIjoyMDIxLCJpc29XZWVrIjoyMX0="
    let url = try #require(
      URL(
        string:
          "https://api.twitch.tv/helix/schedule/segment?broadcaster_id=1234&id=\(segmentID)"
      ))

    await harness.session.stub(
      url: url,
      method: "DELETE",
      status: 204)

    try await harness.twitch.helix(
      endpoint: .deleteChannelStreamScheduleSegment(
        segmentID: segmentID
      ))
  }
}
