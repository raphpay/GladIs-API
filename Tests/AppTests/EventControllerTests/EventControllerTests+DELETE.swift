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
        let user = try await createUser(userType: .admin)
        let token = try await createToken(user: user)
        let event = try await createEvent(clientID: user.requireID())

        // The path for the archive endpoint
        let eventID = try event.requireID()
        let path = "api/events/archive/\(eventID)"

        try await app.test(.DELETE, path, beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
            // Verify the event is archived in the database
            let fetchedEvent = try await getEvent(eventID)
            XCTAssertNotNil(fetchedEvent?.deletedAt)
        })
    }

}

// MARK: - Remove
extension EventControllerTests {
    // Successful Deletion: Tests that a valid event can be successfully deleted.
    func testRemoveEventSuccessfully() async throws {
        // Assume this event is already saved in the database
        let event = try await createEvent()
        let user = try await createUser(userType: .admin)
        let token = try await createToken(user: user)
        
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
        let user = try await createUser(userType: .admin)
        let token = try await createToken(user: user)
        
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
        let user = try await createUser()
        let token = try await createToken(user: user)
        
        try app.test(.DELETE, "api/events/all") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
        }
    }
}
