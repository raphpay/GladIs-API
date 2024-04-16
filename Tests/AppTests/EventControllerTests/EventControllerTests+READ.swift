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

// MARK: - Get All For Clients
extension EventControllerTests {
    // Events Available for Client: Verifies that the method fetches all events for a specific client correctly.
    func testGetAllForClientEventsAvailable() async throws {
        // Create user and authenticate
        let user = try await createUser(userType: .client)
        let token = try await createToken(user: user)

        // Assume helper function to create events for this specific client
        let eventOne = try await createEvent(clientID: user.requireID())
        let eventTwo = try await createEvent(name: "Client Event 2", clientID: user.requireID())

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
        
        try await deleteAll()
    }

    // No Events for Client: Ensures that the method handles cases where no events exist for a specific client.
    func testGetAllForClientNoEventsAvailable() async throws {
        let user = try await createUser(userType: .client)
        let token = try await createToken(user: user)

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
        let admin = try await createUser(userType: .admin)
        let token = try await createToken(user: admin)

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
        let user = try await createUser(userType: .admin)
        let token = try await createToken(user: user)

        // Create and archive events for testing
        let activeEvent = try await createEvent(name: "Active Event", clientID: user.requireID())
        let archivedEvent1 = try await createEvent(name: "Archived Event 1", clientID: user.requireID())
        let archivedEvent2 = try await createEvent(name: "Archived Event 2", clientID: user.requireID())
        try await archiveEvent(archivedEvent1)
        try await archiveEvent(archivedEvent2)

        let path = "api/events/archived"

        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let events = try res.content.decode([Event].self)
            XCTAssertEqual(events.count, 2)
            XCTAssertTrue(events.allSatisfy { $0.deletedAt != nil })  // Assuming 'deletedAt' marks archived events
        }
        
        try await deleteAll()
    }

    func testGetArchivedEventsEmpty() async throws {
        let user = try await createUser(userType: .admin)
        let token = try await createToken(user: user)

        let path = "api/events/archived"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let events = try res.content.decode([Event].self)
            XCTAssertTrue(events.isEmpty)
        }
        
        try await deleteAll()
    }
}

// MARK: - Get Archived Events for Client
extension EventControllerTests {
//    func getArchivedEventsForClient(req: Request) async throws -> [Event] {
//        guard let clientID = req.parameters.get("clientID"),
//            let uuid = UUID(uuidString: clientID) else {
//            throw Abort(.badRequest, reason: "badRequest.uuid")
//        }
//        
//        return try await Event
//            .query(on: req.db)
//            .withDeleted()
//            .filter(\.$client.$id == uuid)
//            .filter(\.$deletedAt != nil)
//            .all()
//    }
    
    func testGetArchivedEventsForClientSuccessfully() async throws {
        let user = try await createUser(userType: .admin)
        let clientOne = try await createUser(userType: .client)
        let clientTwo = try await createUser(userType: .client)
        let token = try await createToken(user: user)
        
        let activeEvent = try await createEvent(name: "Active Event", clientID: user.requireID())
        let archivedEvent1 = try await createEvent(name: "Archived Event 1", clientID: clientOne.requireID())
        let archivedEvent2 = try await createEvent(name: "Archived Event 2", clientID: clientTwo.requireID())
        try await archiveEvent(archivedEvent1)
        try await archiveEvent(archivedEvent2)

        let clientID = try clientOne.requireID()
        let path = "api/events/client/archived/\(clientID)"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let events = try res.content.decode([Event].self)
            XCTAssertEqual(events.count, 1)
        }
        
        try await deleteAll()
    }
    
    func testGetArchivedEventsForClientBadUUID() async throws {
        let user = try await createUser(userType: .admin)
        let token = try await createToken(user: user)
        let uuid = "1234"
        
        let path = "api/events/client/archived/\(uuid)"
        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
}
