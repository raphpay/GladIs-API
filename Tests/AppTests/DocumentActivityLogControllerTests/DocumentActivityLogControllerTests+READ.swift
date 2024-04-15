//
//  DocumentActivityLogControllerTests+READ.swift
//  
//
//  Created by Raphaël Payet on 15/04/2024.
//

@testable import App
import XCTVapor

extension DocumentActivityLogControllerTests {
    // Happy Path: When the database has multiple logs stored.
    func testGetAllDocumentActivityLogs() async throws {
        let user = try await createUser(app: app, username: expectedUsername)
        let token = try await createToken(app: app, user: user)
        
        let document = Document(name: expectedDocumentName, path: expectedDocPath, status: .none)
        try await document.save(on: app.db)

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
        let user = try await createUser(app: app, username: expectedUsername)
        let token = try await createToken(app: app, user: user)
        
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
