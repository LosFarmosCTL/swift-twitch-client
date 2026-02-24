import Foundation
import Mocker
import XCTest

@testable import Twitch

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class ScheduleTests: XCTestCase {
  private var twitch: TwitchClient!

  override func setUpWithError() throws {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockingURLProtocol.self]
    let urlSession = URLSession(configuration: configuration)

    twitch = TwitchClient(
      authentication: .init(
        oAuth: "1234567989", clientID: "abcdefghijkl", userID: "1234", userLogin: "user"),
      urlSession: urlSession)
  }

  func testGetChanneliCalendar() async throws {
    let url = URL(
      string: "https://api.twitch.tv/helix/schedule/icalendar?broadcaster_id=141981764")!

    Mock(
      url: url, contentType: .json, statusCode: 200,
      data: [.get: MockedData.getChanneliCalendarICS]
    ).register()

    let calendar = try await twitch.helix(
      endpoint: .getChanneliCalendar(broadcasterID: "141981764")
    )

    XCTAssertTrue(calendar.contains("BEGIN:VCALENDAR"))
    XCTAssertTrue(calendar.contains("NAME:TwitchDev"))
    XCTAssertTrue(calendar.contains("SUMMARY:TwitchDev Monthly Update // July 1, 2021"))
  }

  func testUpdateChannelStreamSchedule() async throws {
    let url = URL(
      string:
        "https://api.twitch.tv/helix/schedule/settings?broadcaster_id=1234&is_vacation_enabled=true&vacation_start_time=2021-05-16T00:00:00Z&vacation_end_time=2021-05-23T00:00:00Z&timezone=America/New_York"
    )!

    var request = URLRequest(url: url)
    request.httpMethod = "PATCH"

    var mock = Mock(request: request, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    let startTime = try XCTUnwrap(
      Date("2021-05-16T00:00:00Z", strategy: .iso8601))
    let endTime = try XCTUnwrap(
      Date("2021-05-23T00:00:00Z", strategy: .iso8601))

    try await twitch.helix(
      endpoint: .updateChannelStreamSchedule(
        isVacationEnabled: true,
        vacationStartTime: startTime,
        vacationEndTime: endTime,
        timezone: "America/New_York"
      ))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }

  func testCreateChannelStreamScheduleSegment() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/schedule/segment")!

    Mock(
      url: url, ignoreQuery: true, contentType: .json, statusCode: 200,
      data: [.post: MockedData.createChannelStreamScheduleSegmentJSON]
    ).register()

    let startTime = try XCTUnwrap(
      Date("2021-07-01T18:00:00Z", strategy: .iso8601))

    let schedule = try await twitch.helix(
      endpoint: .createChannelStreamScheduleSegment(
        startTime: startTime,
        timezone: "America/New_York",
        duration: 60,
        isRecurring: false,
        categoryID: "509670",
        title: "TwitchDev Monthly Update // July 1, 2021"
      ))

    XCTAssertEqual(schedule.broadcasterID, "141981764")
    XCTAssertEqual(schedule.broadcasterLogin, "twitchdev")
    XCTAssertNil(schedule.vacation)

    let segment = try XCTUnwrap(schedule.segments.first)
    XCTAssertEqual(
      segment.id,
      "eyJzZWdtZW50SUQiOiJlNGFjYzcyNC0zNzFmLTQwMmMtODFjYS0yM2FkYTc5NzU5ZDQiLCJpc29ZZWFyIjoyMDIxLCJpc29XZWVrIjoyNn0="
    )
    XCTAssertEqual(segment.title, "TwitchDev Monthly Update // July 1, 2021")
    XCTAssertEqual(segment.startTime.formatted(.iso8601), "2021-07-01T18:00:00Z")
    XCTAssertEqual(segment.endTime.formatted(.iso8601), "2021-07-01T19:00:00Z")
    XCTAssertNil(segment.canceledUntil)
    XCTAssertEqual(segment.category?.id, "509670")
    XCTAssertEqual(segment.category?.name, "Science & Technology")
    XCTAssertFalse(segment.isRecurring)
  }

  func testUpdateChannelStreamScheduleSegment() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/schedule/segment")!

    var request = URLRequest(url: url)
    request.httpMethod = "PATCH"

    let mock = Mock(
      request: request, ignoreQuery: true, contentType: .json, statusCode: 200,
      data: MockedData.updateChannelStreamScheduleSegmentJSON)
    mock.register()

    let schedule = try await twitch.helix(
      endpoint: .updateChannelStreamScheduleSegment(
        segmentID:
          "eyJzZWdtZW50SUQiOiJlNGFjYzcyNC0zNzFmLTQwMmMtODFjYS0yM2FkYTc5NzU5ZDQiLCJpc29ZZWFyIjoyMDIxLCJpc29XZWVrIjoyNn0=",
        duration: 120
      ))

    let segment = try XCTUnwrap(schedule.segments.first)
    XCTAssertEqual(segment.endTime.formatted(.iso8601), "2021-07-01T20:00:00Z")
    XCTAssertEqual(segment.category?.name, "Science & Technology")
    XCTAssertFalse(segment.isRecurring)
  }

  func testDeleteChannelStreamScheduleSegment() async throws {
    let url = URL(string: "https://api.twitch.tv/helix/schedule/segment")!

    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"

    var mock = Mock(request: request, ignoreQuery: true, statusCode: 204)
    let completionExpectation = expectationForCompletingMock(&mock)
    mock.register()

    try await twitch.helix(
      endpoint: .deleteChannelStreamScheduleSegment(
        segmentID:
          "eyJzZWdtZW50SUQiOiI4Y2EwN2E2NC0xYTZkLTRjYWItYWE5Ni0xNjIyYzNjYWUzZDkiLCJpc29ZZWFyIjoyMDIxLCJpc29XZWVrIjoyMX0="
      ))

    await fulfillment(of: [completionExpectation], timeout: 2.0)
  }
}
