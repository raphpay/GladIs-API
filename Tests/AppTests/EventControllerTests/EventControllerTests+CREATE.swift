//
//  EventControllerTests.swift
//
//
//  Created by Raphaël Payet on 15/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Create
extension EventControllerTests {
    // Happy Path: A user that is allowed to create events successfully creates an event.
    func testCreateEventSuccess() async throws {
        let user = try await createUser()
        let token = try await createToken(user: user)
        let clientID = UUID()
        let eventInput = Event.Input(name: expectedEventName, date: Date.now.timeIntervalSince1970, clientID: clientID)
        
        try app.test(.POST, "api/events", beforeRequest: { req in
            try req.content.encode(eventInput)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let event = try res.content.decode(Event.self)
            XCTAssertEqual(event.name, eventInput.name)
            XCTAssertEqual(event.$client.id, eventInput.clientID)
        })
    }

    // Unauthorized User Type: An employee tries to create an event but is unauthorized.
    func testCreateEventUnauthorizedUser() async throws {
        let user = try await createUser(userType: .employee)
        let token = try await createToken(user: user)
        let clientID = UUID()
        let eventInput = Event.Input(name: expectedEventName, date: Date.now.timeIntervalSince1970, clientID: clientID)
        
        try app.test(.POST, "api/events", beforeRequest: { req in
            try req.content.encode(eventInput)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.event.employee"))
        })
    }

    // Client Event Limit: A client that has already reached the event limit tries to create another event.
    func testCreateEventClientLimitReached() async throws {
        let user = try await createUser(userType: .client)
        let token = try await createToken(user: user)
        let eventInput = Event.Input(name: expectedEventName, date: Date.now.timeIntervalSince1970, clientID: try user.requireID())
        
        for index in 0..<5 {
            let event = Event(name: "\(expectedEventName) \(index)", date: Date.now.timeIntervalSince1970, clientID: try user.requireID())
            try await event.save(on: app.db)
        }

        try app.test(.POST, "api/events", beforeRequest: { req in
            try req.content.encode(eventInput)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .forbidden)
            XCTAssertTrue(res.body.string.contains("forbidden.event.tooManyEvents"))
        })
    }
}


// MARK: - Create Max Login
extension EventControllerTests {
    func testCreateMaxLoginEventSuccessfully() async throws {
        let user = try await createUser(userType: .admin)
        let token = try await createToken(user: user)
        // Event input simulation
        let eventInput = Event.Input(name: "Max Login Attempt", date: Date().timeIntervalSince1970, clientID: try user.requireID())
        let path = "api/events/maxLogin"

        try await app.test(.POST, path, beforeRequest: { req in
            try req.content.encode(eventInput)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let event = try res.content.decode(Event.self)
            XCTAssertNotNil(event.id)
            XCTAssertEqual(event.name, eventInput.name)
            XCTAssertEqual(event.$client.id, eventInput.clientID)

            // Verify the event is saved in the database
            let foundEvent = try await Event.find(event.id, on: app.db)
            XCTAssertNotNil(foundEvent)
            XCTAssertEqual(foundEvent?.name, eventInput.name)
        })
    }

}
