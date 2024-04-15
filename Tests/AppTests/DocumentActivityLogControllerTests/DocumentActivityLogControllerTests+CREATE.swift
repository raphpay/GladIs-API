//
//  DocumentActivityLogControllerTests+CREATE.swift
//  
//
//  Created by Raphaël Payet on 15/04/2024.
//

@testable import App
import XCTVapor

extension DocumentActivityLogControllerTests {
    
    // Happy Path: The document and user exist, and the log is created successfully.
    func testCreateDocumentActivityLog() async throws {
        // Create user and token
        let user = try await createUser()
        let token = try await createToken(user: user)
        let document = try await createDocument()
    
        
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
    func testCreateDocumentActivityLogDocumentNotFound() async throws {
        let user = try await createUser()
        let token = try await createToken(user: user)
        
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
    func testCreateDocumentActivityLogUserNotFound() async throws {
        let user = try await createUser()
        let token = try await createToken(user: user)
        let document = try await createDocument()

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
    func testCreateDocumentActivityLogInvalidToken() async throws {
        let document = try await createDocument()
        let user = try await createUser()
        
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
