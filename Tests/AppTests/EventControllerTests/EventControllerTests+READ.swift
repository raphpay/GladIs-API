//
//  EventControllerTests+READ.swift
//
//
//  Created by Raphaël Payet on 15/04/2024.
//

@testable import App
import XCTVapor


// MARK: - Get all
extension EventControllerTests {
    func testGetAllEventsSuccessfully() async throws {
        let user = try await createUser(userType: .admin)
        let token = try await createToken(user: user)

        // Create multiple events for testing
        let eventOne = try await createEvent(name: expectedEventName, clientID: user.requireID())
        let eventTwo = try await createEvent(name: "Event 2", clientID: user.requireID())

        let path = "api/events"

        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let events = try res.content.decode([Event].self)
            XCTAssertEqual(events.count, 2)
            XCTAssertEqual(events[0].name, eventOne.name)
            XCTAssertEqual(events[0].name, expectedEventName)
            XCTAssertEqual(events[1].name, eventTwo.name)
        }
    }

    func testGetAllEventsEmpty() async throws {
        let user = try await createUser(userType: .admin)
        let token = try await createToken(user: user)

        let path = "api/events"

        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let events = try res.content.decode([Event].self)
            XCTAssertTrue(events.isEmpty)
        }
    }

}

