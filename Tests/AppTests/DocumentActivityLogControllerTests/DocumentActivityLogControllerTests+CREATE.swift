//
//  DocumentActivityLogControllerTests+CREATE.swift
//  
//
//  Created by Raphaël Payet on 15/04/2024.
//

@testable import App
import XCTVapor

// MARK: - CREATE
extension DocumentActivityLogControllerTests {
    
    func testCreateDocumentActivityLogForDocumentSucceed() async throws {
       let user = try await User.create(username: expectedUsername, on: app.db)
       let client = try await User.create(username: expectedClientUsername, userType: .client, on: app.db)
       let token = try await Token.create(for: user, on: app.db)
       let document = try await Document.create(name: expectedDocumentName, path: expectedDocPath, on: app.db)
       let actorIsAdmin = true
       let logInput = DocumentActivityLog.Input(action: expectedAction,
                                                actorIsAdmin: actorIsAdmin,
                                                actorID: try user.requireID(),
                                                documentID: try document.requireID(), formID: nil,
                                                clientID: try client.requireID())

       try app.test(.POST, "api/documentActivityLogs", beforeRequest: { req in
           try req.content.encode(logInput)
           req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
       }, afterResponse: { res in
           XCTAssertEqual(res.status, .ok)
           let receivedLog = try res.content.decode(DocumentActivityLog.self)
           XCTAssertEqual(receivedLog.actorUsername, expectedUsername)
           XCTAssertEqual(receivedLog.name, expectedDocumentName)
           XCTAssertEqual(receivedLog.action, expectedAction)
           XCTAssertEqual(receivedLog.actorIsAdmin, actorIsAdmin)
           XCTAssertEqual(receivedLog.$document.id, try document.requireID())
           XCTAssertEqual(receivedLog.$client.id, try user.requireID())
       })
    }

    func testCreateDocumentActivityLogForFormSucceed() async throws {
       let user = try await User.create(username: expectedUsername, on: app.db)
       let client = try await User.create(username: expectedClientUsername, userType: .client, on: app.db)
       let clientID = try client.requireID()
       let token = try await Token.create(for: user, on: app.db)
       let form = try await Form.create(title: expectedFormTitle, value: expectedFormValue, clientID: clientID.uuidString, path: expectedDocPath, on: app.db)
       let actorIsAdmin = true
       let logInput = DocumentActivityLog.Input(action: .creation, actorIsAdmin: actorIsAdmin,
                                                actorID: try user.requireID(),
                                                documentID: nil, formID: try form.requireID(),
                                                clientID: clientID)

       try app.test(.POST, "api/documentActivityLogs", beforeRequest: { req in
           try req.content.encode(logInput)
           req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
       }, afterResponse: { res in
           XCTAssertEqual(res.status, .ok)
           let receivedLog = try res.content.decode(DocumentActivityLog.self)
           XCTAssertEqual(receivedLog.actorUsername, expectedUsername)
           XCTAssertEqual(receivedLog.name, expectedFormTitle)
           XCTAssertEqual(receivedLog.action, expectedAction)
           XCTAssertEqual(receivedLog.actorIsAdmin, actorIsAdmin)
           XCTAssertEqual(receivedLog.$form.id, try form.requireID())
           XCTAssertEqual(receivedLog.$client.id, try user.requireID())
       })
    }
    
    func testCreatedDocumentActivityLogWithInexistantUserFails() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let client = try await User.create(username: expectedClientUsername, userType: .client, on: app.db)
        let clientID = try client.requireID()
        let token = try await Token.create(for: user, on: app.db)
        let form = try await Form.create(title: expectedFormTitle, value: expectedFormValue, clientID: clientID.uuidString, path: expectedDocPath, on: app.db)
        let actorIsAdmin = true
        let logInput = DocumentActivityLog.Input(action: .creation, actorIsAdmin: actorIsAdmin, actorID: UUID(), documentID: nil, formID: try form.requireID(), clientID: clientID)

        try app.test(.POST, "api/documentActivityLogs", beforeRequest: { req in
           try req.content.encode(logInput)
           req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
       }, afterResponse: { res in
           XCTAssertEqual(res.status, .notFound)
           XCTAssertTrue(res.body.string.contains("notFound.user"))
       })
    }

    func testCreatedDocumentActivityLogForInexistantDocumentFails() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let client = try await User.create(username: expectedClientUsername, userType: .client, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let _ = try await Document.create(name: expectedDocumentName, path: expectedDocPath, on: app.db)
        let actorIsAdmin = true
        let logInput = DocumentActivityLog.Input(action: .creation, actorIsAdmin: actorIsAdmin, actorID: try user.requireID(), documentID: UUID(), formID: nil, clientID: try client.requireID())

        try app.test(.POST, "api/documentActivityLogs", beforeRequest: { req in
           try req.content.encode(logInput)
           req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
       }, afterResponse: { res in
           XCTAssertEqual(res.status, .notFound)
           XCTAssertTrue(res.body.string.contains("notFound.document"))
       })
    }

    func testCreatedDocumentActivityLogForInexistantFormFails() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let client = try await User.create(username: expectedClientUsername, userType: .client, on: app.db)
        let clientID = try client.requireID()
        let token = try await Token.create(for: user, on: app.db)
        let _ = try await Form.create(title: expectedFormTitle, value: expectedFormValue, clientID: clientID.uuidString, path: expectedDocPath, on: app.db)
        let actorIsAdmin = true
        let logInput = DocumentActivityLog.Input(action: .creation, actorIsAdmin: actorIsAdmin, actorID: try user.requireID(), documentID: nil, formID: UUID(), clientID: clientID)

        try app.test(.POST, "api/documentActivityLogs", beforeRequest: { req in
           try req.content.encode(logInput)
           req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
       }, afterResponse: { res in
           XCTAssertEqual(res.status, .notFound)
           XCTAssertTrue(res.body.string.contains("notFound.form"))
       })
    }

    func testCreatedDocumentActivityLogWithoutFormOrDocumentFails() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let client = try await User.create(username: expectedClientUsername, userType: .client, on: app.db)
        let clientID = try client.requireID()
        let token = try await Token.create(for: user, on: app.db)
        let actorIsAdmin = true
        let logInput = DocumentActivityLog.Input(action: .creation, actorIsAdmin: actorIsAdmin, actorID: try user.requireID(), documentID: nil, formID: nil, clientID: clientID)

        try app.test(.POST, "api/documentActivityLogs", beforeRequest: { req in
           try req.content.encode(logInput)
           req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
       }, afterResponse: { res in
           XCTAssertEqual(res.status, .badRequest)
           XCTAssertTrue(res.body.string.contains("badRequest.documentOrForm"))
       })
    }
}
