//
//  EventControllerTests+DELETE.swift
//  
//
//  Created by Raphaël Payet on 15/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Archive
extension EventControllerTests {
    func testArchiveEventSuccessfully() async throws {
        // Setup: Create a user, create an event, then attempt to archive
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let event = try await Event.create(name: expectedEventName, on: app.db)

        // The path for the archive endpoint
        let eventID = try event.requireID()
        let path = "api/events/archive/\(eventID)"

        try await app.test(.DELETE, path, beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
            // Verify the event is archived in the database
            let fetchedEvent = try await Event.get(eventID, on: app.db)
            XCTAssertNotNil(fetchedEvent?.deletedAt)
        })
    }

}

// MARK: - Remove
extension EventControllerTests {
    // Successful Deletion: Tests that a valid event can be successfully deleted.
    func testRemoveEventSuccessfully() async throws {
        // Assume this event is already saved in the database
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let event = try await Event.create(name: expectedEventName, on: app.db)
        
        let uuid = try event.requireID()
        let path = "api/events/\(uuid)"
        try await app.test(.DELETE, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
            let foundEvent = try await Event.find(event.id, on: app.db)
            XCTAssertNil(foundEvent)
        }
    }

    // Invalid Event ID Format: Tests that the system handles improperly formatted event IDs correctly.
    func testRemoveEventInvalidUUID() async throws {
        let invalidUUID = "1234"
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        try app.test(.DELETE, "api/events/\(invalidUUID)", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
        })
    }
}

// MARK: - Remove all
extension EventControllerTests {
    func testDeleteAllEvents() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        try app.test(.DELETE, "api/events/all") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
        }
    }
}
