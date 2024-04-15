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
    // Successful Update: Verify that the method updates an event's details correctly when provided with valid input and authorization.
    func testUpdateEventSuccessfully() async throws {
        let user = try await createUser(userType: .admin)
        let token = try await createToken(user: user)
        let event = try await createEvent(clientID: user.requireID())
        
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
        let user = try await createUser(userType: .admin)
        let token = try await createToken(user: user)
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
