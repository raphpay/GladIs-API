//
//  DocumentActivityLogControllerTests.swift
//
//
//  Created by Raphaël Payet on 15/04/2024.
//

@testable import App
import XCTVapor

final class DocumentActivityLogControllerTests: XCTestCase {
    
    var app: Application!
    // Expected Properties
    let expectedUsername = "testuser"
    let expectedDocPath = "test/test"
    let expectedDocumentName = "Test Document"
    
    override func setUp() async throws {
        try await super.setUp()
        
        app = Application(.testing)
        try! await configure(app)
    }
    
    override func tearDown() {
        app.shutdown()
        super.tearDown()
    }
}

// MARK: - CREATE
extension DocumentActivityLogControllerTests {
    
    // Happy Path: The document and user exist, and the log is created successfully.
    func testCreateDocumentActivityLog() throws {
        // Create user and token
        let user = User(firstName: "testFirstName", lastName: "testLastName",
                        phoneNumber: "0601234567", username: expectedUsername,
                        password: "PasswordTest15", email: "test@test.com",
                        firstConnection: true, userType: .admin)
        try user.save(on: app.db).wait()
        
        let token = try Token.generate(for: user)
        try token.save(on: app.db).wait()
        
        // Create a document
        let document = Document(name: expectedDocumentName, path: expectedDocPath, status: .none)
        try document.save(on: app.db).wait()
        
        let logInput = DocumentActivityLog.Input(action: .creation, actorIsAdmin: false,
                                                 actorID: try user.requireID(), documentID: try document.requireID(),
                                                 clientID: try user.requireID())

        // Act
        try app.test(.POST, "api/documentActivityLogs", beforeRequest: { req in
            try req.content.encode(logInput)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res in
            // Assert
            XCTAssertEqual(res.status, .ok)
            let receivedLog = try res.content.decode(DocumentActivityLog.self)
            XCTAssertEqual(receivedLog.actorUsername, expectedUsername)
            XCTAssertEqual(receivedLog.name, expectedDocumentName)
        })
    }
    
    // Document Not Found: The document does not exist.
    func testCreateDocumentActivityLogDocumentNotFound() throws {
        let user = User(firstName: "testFirstName", lastName: "testLastName",
                        phoneNumber: "0601234567", username: expectedUsername,
                        password: "PasswordTest15", email: "test@test.com",
                        firstConnection: true, userType: .admin)
        try user.save(on: app.db).wait()

        let token = try Token.generate(for: user)
        try token.save(on: app.db).wait()
        
        let logInput = DocumentActivityLog.Input(action: .creation, actorIsAdmin: false,
                                                 actorID: try user.requireID(),
                                                 documentID: UUID(), // Non-existing document ID
                                                 clientID: try user.requireID())

        try app.test(.POST, "api/documentActivityLogs", beforeRequest: { req in
            try req.content.encode(logInput)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.document"))
        })
    }

    // User Not Found: The user does not exist.
    func testCreateDocumentActivityLogUserNotFound() throws {
        let document = Document(name: expectedDocumentName, path: expectedDocPath, status: .none)
        try document.save(on: app.db).wait()

        let user = User(firstName: "testFirstName", lastName: "testLastName",
                        phoneNumber: "0601234567", username: expectedUsername,
                        password: "PasswordTest15", email: "test@test.com",
                        firstConnection: true, userType: .admin)
        try user.save(on: app.db).wait()
        
        let token = try Token.generate(for: user)
        try token.save(on: app.db).wait()

        let logInput = DocumentActivityLog.Input(action: .creation, actorIsAdmin: false,
                                                 actorID: UUID(),
                                                 documentID: try document.requireID(),
                                                 clientID: UUID())

        try app.test(.POST, "api/documentActivityLogs", beforeRequest: { req in
            try req.content.encode(logInput)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        })
    }

    // Invalid Token: The authentication token is missing or invalid.
    func testCreateDocumentActivityLogInvalidToken() throws {
        let document = Document(name: expectedDocumentName, path: expectedDocPath, status: .none)
        try document.save(on: app.db).wait()

        let user = User(firstName: "testFirstName", lastName: "testLastName",
                        phoneNumber: "0601234567", username: expectedUsername,
                        password: "PasswordTest15", email: "test@test.com",
                        firstConnection: true, userType: .admin)
        try user.save(on: app.db).wait()
        
        let logInput = DocumentActivityLog.Input(action: .creation, actorIsAdmin: false,
                                                 actorID: try user.requireID(),
                                                 documentID: try document.requireID(),
                                                 clientID: try user.requireID())

        try app.test(.POST, "api/documentActivityLogs", beforeRequest: { req in
            try req.content.encode(logInput)
            req.headers.bearerAuthorization = BearerAuthorization(token: "invalidtoken")
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .unauthorized)
        })
    }
}

// MARK: - READ
extension DocumentActivityLogControllerTests {
    // Happy Path: When the database has multiple logs stored.
    func testGetAllDocumentActivityLogs() async throws {
        // Arrange: create some logs
        let user = User(firstName: "testFirstName", lastName: "testLastName",
                        phoneNumber: "0601234567", username: expectedUsername,
                        password: "PasswordTest15", email: "test@test.com",
                        firstConnection: true, userType: .admin)
        try await user.save(on: app.db)
        
        let token = try Token.generate(for: user)
        try await token.save(on: app.db)
        
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
        // Act: Perform the test on an empty database
        let user = User(firstName: "testFirstName", lastName: "testLastName",
                        phoneNumber: "0601234567", username: expectedUsername,
                        password: "PasswordTest15", email: "test@test.com",
                        firstConnection: true, userType: .admin)
        try await user.save(on: app.db)
        
        let token = try Token.generate(for: user)
        try await token.save(on: app.db)
        
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

// MARK: - DELETE
extension DocumentActivityLogControllerTests {
    func testDeleteAllDocumentActivityLogs() async throws {
        let user = User(firstName: "testFirstName", lastName: "testLastName",
                        phoneNumber: "0601234567", username: expectedUsername,
                        password: "PasswordTest15", email: "test@test.com",
                        firstConnection: true, userType: .admin)
        try await user.save(on: app.db)
        
        let token = try Token.generate(for: user)
        try await token.save(on: app.db)
        
        try app.test(.DELETE, "api/documentActivityLogs") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
        }
    }
}
