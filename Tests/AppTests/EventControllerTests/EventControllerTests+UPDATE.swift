//
//  EventControllerTests+READ.swift
//
//
//  Created by Raphaël Payet on 15/04/2024.
//

@testable import App
import XCTVapor


// MARK: - Update
extension EventControllerTests {
    // Successful Update: Verify that the method updates an event's details correctly when provided with valid input and authorization.
    func testUpdateEventSuccessfully() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let event = try await Event.create(name: expectedEventName, clientID: user.requireID(), on: app.db)
        
        let updatedEventData = Event.Input(name: updatedEventName, date: Date().timeIntervalSince1970, clientID: try user.requireID())
        let eventID = try event.requireID()
        let path = "api/events/\(eventID)"

        try await app.test(.PUT, path, beforeRequest: { req in
            try req.content.encode(updatedEventData)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let updatedEvent = try res.content.decode(Event.self)
            XCTAssertEqual(updatedEvent.name, updatedEventName)
            XCTAssertNotEqual(updatedEvent.name, event.name)
            // Verify the event is updated in the database
            let fetchedEvent = try await Event.find(event.id, on: app.db)
            XCTAssertEqual(fetchedEvent?.name, updatedEventName)
        })
    }

    // Event Not Found: Test the scenario where the event ID provided does not exist.
    func testUpdateEventNotFound() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let nonExistingID = UUID()

        let updatedEventData = Event.Input(name: updatedEventName, date: Date().timeIntervalSince1970, clientID: try user.requireID())
        let path = "api/events/\(nonExistingID)"

        try app.test(.PUT, path, beforeRequest: { req in
            try req.content.encode(updatedEventData)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }
}

// MARK: - Restore
extension EventControllerTests {
    // Successful Restore: Verify the method successfully restores a previously archived event.
    func testRestoreEventSuccessfully() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let event = try await Event.create(name: expectedEventName, clientID: user.requireID(), on: app.db)
        
        // Simulate archiving the event
        try await Event.archive(event, on: app.db)

        // The path for the restore endpoint
        let eventID = try event.requireID()
        let path = "api/events/restore/\(eventID)"

        try await app.test(.PUT, path, beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let restoredEvent = try res.content.decode(Event.self)
            XCTAssertNotNil(restoredEvent.deletedAt == nil)  // Check if the event is un-archived
            let fetchedEvent = try await Event.query(on: app.db)
                .withDeleted()
                .first()
            XCTAssertNotNil(fetchedEvent)
            XCTAssertNil(fetchedEvent?.deletedAt)
        })
    }

    // Event Not Found: Test the scenario where the event ID provided does not correspond to any archived event.
    func testRestoreEventNotFound() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let nonExistingID = UUID()

        let path = "api/events/restore/\(nonExistingID)"

        try app.test(.PUT, path, beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    // Invalid Event ID: Ensure the method properly handles malformed or invalid event IDs.
    func testRestoreEventInvalidUUID() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let invalidUUID = "1234"

        let path = "api/events/restore/\(invalidUUID)"

        try app.test(.PUT, path, beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
        })
    }

}
