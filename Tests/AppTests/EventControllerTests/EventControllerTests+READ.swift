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
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)

        // Create multiple events for testing
        let eventOne = try await Event.create(name: expectedEventName, clientID: user.requireID(), on: app.db)
        let eventTwo = try await Event.create(name: expectedEventName, clientID: user.requireID(), on: app.db)

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
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)

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

// MARK: - Get All For Clients
extension EventControllerTests {
    // Events Available for Client: Verifies that the method fetches all events for a specific client correctly.
    func testGetAllForClientEventsAvailable() async throws {
        // Create user and authenticate
        let user = try await User.create(username: expectedUsername, userType: .client, on: app.db)
        let token = try await Token.create(for: user, on: app.db)

        // Assume helper function to create events for this specific client
        let eventOne = try await Event.create(name: expectedEventName, clientID: user.requireID(), on: app.db)
        let eventTwo = try await Event.create(name: "Client Event 2", clientID: user.requireID(), on: app.db)

        let userID = try user.requireID()
        let path = "api/events/client/\(userID)"

        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let events = try res.content.decode([Event].self)
            XCTAssertEqual(events.count, 2)
            XCTAssertEqual(events.first?.name, eventOne.name)
            XCTAssertEqual(events.first?.name, expectedEventName)
            XCTAssertEqual(events.last?.name, eventTwo.name)
        }
        
        try await Event.deleteAll(on: app.db)
    }

    // No Events for Client: Ensures that the method handles cases where no events exist for a specific client.
    func testGetAllForClientNoEventsAvailable() async throws {
        // Create user and authenticate
        let user = try await User.create(username: expectedUsername, userType: .client, on: app.db)
        let token = try await Token.create(for: user, on: app.db)

        let userID = try user.requireID()
        let path = "api/events/client/\(userID)"

        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let events = try res.content.decode([Event].self)
            XCTAssertTrue(events.isEmpty)
        }
    }

    // Invalid Client ID: Tests the response when the client ID provided does not match any existing clients or is malformed.
    func testGetAllForClientInvalidClientID() async throws {
        let invalidClientID = "invalid-uuid"

        // Create user and authenticate
        let user = try await User.create(username: expectedUsername, userType: .client, on: app.db)
        let token = try await Token.create(for: user, on: app.db)

        let path = "api/events/client/\(invalidClientID)"

        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.uuid"))
        }
    }

}

// MARK: - Get Archived Events
extension EventControllerTests {
    func testGetArchivedEventsSuccessfully() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)

        // Create and archive events for testing
        let activeEvent = try await Event.create(name: "Active Event", clientID: user.requireID(), on: app.db)
        let archivedEvent1 = try await Event.create(name: "Archived Event 1", clientID: user.requireID(), on: app.db)
        let archivedEvent2 = try await Event.create(name: "Archived Event 2", clientID: user.requireID(), on: app.db)
        try await Event.archive(archivedEvent1, on: app.db)
        try await Event.archive(archivedEvent2, on: app.db)

        let path = "api/events/archived"

        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let events = try res.content.decode([Event].self)
            XCTAssertEqual(events.count, 2)
            XCTAssertTrue(events.allSatisfy { $0.deletedAt != nil })  // Assuming 'deletedAt' marks archived events
        }
        
        try await Event.deleteAll(on: app.db)
    }

    func testGetArchivedEventsEmpty() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)

        let path = "api/events/archived"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let events = try res.content.decode([Event].self)
            XCTAssertTrue(events.isEmpty)
        }
        
        try await Event.deleteAll(on: app.db)
    }
}

// MARK: - Get Archived Events for Client
extension EventControllerTests {
    func testGetArchivedEventsForClientSuccessfully() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let clientOne = try await User.create(username: expectedUsername, userType: .client, on: app.db)
        let clientTwo = try await User.create(username: expectedUsername, userType: .client, on: app.db)
        
        let activeEvent = try await Event.create(name: "Active Event", clientID: user.requireID(), on: app.db)
        let archivedEvent1 = try await Event.create(name: "Archived Event 1", clientID: clientOne.requireID(), on: app.db)
        let archivedEvent2 = try await Event.create(name: "Archived Event 2", clientID: clientTwo.requireID(), on: app.db)
        try await Event.archive(archivedEvent1, on: app.db)
        try await Event.archive(archivedEvent2, on: app.db)

        let clientID = try clientOne.requireID()
        let path = "api/events/client/archived/\(clientID)"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let events = try res.content.decode([Event].self)
            XCTAssertEqual(events.count, 1)
        }
        
        try await Event.deleteAll(on: app.db)
    }
    
    func testGetArchivedEventsForClientBadUUID() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let uuid = "1234"
        
        let path = "api/events/client/archived/\(uuid)"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
}
