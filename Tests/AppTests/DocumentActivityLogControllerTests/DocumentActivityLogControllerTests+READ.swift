//
//  DocumentActivityLogControllerTests+READ.swift
//  
//
//  Created by Raphaël Payet on 15/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Get All
extension DocumentActivityLogControllerTests {
    // Happy Path: When the database has multiple logs stored.
    func testGetAllDocumentActivityLogs() async throws {
        let user = try await createUser()
        let token = try await createToken(user: user)
        let document = try await createDocument()

        for _ in 0..<3 {
            let log = DocumentActivityLog(name: document.name, actorUsername: user.username,
                                          action: .visualisation, actionDate: Date.now,
                                          actorIsAdmin: false, documentID: try document.requireID(),
                                          clientID: UUID())
            try await log.save(on: app.db)
        }

        // Act: Perform the test
        try app.test(.GET, "api/documentActivityLogs", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            
            // Assert: Check if the response contains exactly 3 logs
            let logs = try res.content.decode([DocumentActivityLog].self)
            XCTAssertEqual(logs.count, 3)
        })
    }
    
    // No Logs Available: When there are no logs in the database.
    func testGetAllDocumentActivityLogsNoLogsAvailable() async throws {
        let user = try await createUser()
        let token = try await createToken(user: user)
        
        try app.test(.GET, "api/documentActivityLogs", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            
            // Assert: Ensure the array is empty
            let logs = try res.content.decode([DocumentActivityLog].self)
            XCTAssertTrue(logs.isEmpty)
        })
    }

    // Authentication Tests: Validate that unauthorized access is properly handled.
    func testGetAllDocumentActivityLogsUnauthorized() throws {
        // Act: Attempt to access without a valid token
        try app.test(.GET, "api/documentActivityLogs", afterResponse: { res in
            // Assert: Check for unauthorized status
            XCTAssertEqual(res.status, .unauthorized)
        })
    }
}

// MARK: - Get Logs For Client
extension DocumentActivityLogControllerTests {
    // Logs Available: The database has logs for the specified client.
    func testGetLogsForClientWithLogsAvailable() async throws {
        // Arrange
        let clientID = UUID()
        let user = try await createUser()
        let token = try await createToken(user: user)
        let document = try await createDocument()

        for _ in 0..<3 {
            let log = DocumentActivityLog(name: document.name,
                                          actorUsername: user.username,
                                          action: .visualisation,
                                          actionDate: Date(),
                                          actorIsAdmin: false,
                                          documentID: try document.requireID(),
                                          clientID: clientID)
            try await log.save(on: app.db)
        }

        // Act & Assert
        try app.test(.GET, "api/documentActivityLogs/\(clientID)", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let logs = try res.content.decode([DocumentActivityLog].self)
            XCTAssertEqual(logs.count, 3)
            for log in logs {
                XCTAssertEqual(log.$client.id, clientID)
            }
        })
    }

    // No Logs Available: There are no logs for the specified client.
    func testGetLogsForClientWithNoLogsAvailable() async throws {
        // Arrange
        let clientID = UUID()  // A client ID with no associated logs
        let user = try await createUser()
        let token = try await createToken(user: user)

        // Act & Assert
        try app.test(.GET, "api/documentActivityLogs/\(clientID)", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let logs = try res.content.decode([DocumentActivityLog].self)
            XCTAssertTrue(logs.isEmpty)
        })
    }

    // Invalid Client ID: The client ID provided does not exist or is formatted incorrectly.
    func testGetLogsForClientWithInvalidClientID() async throws {
        // Arrange
        let invalidClientID = "invalid-uuid"
        let user = try await createUser()
        let token = try await createToken(user: user)

        // Act & Assert
        try app.test(.GET, "api/documentActivityLogs/\(invalidClientID)", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
        })
    }

}
