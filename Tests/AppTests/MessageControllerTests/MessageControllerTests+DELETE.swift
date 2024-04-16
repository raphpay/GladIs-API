//
//  MessageControllerTests+CREATE.swift
//
//
//  Created by Raphaël Payet on 16/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Delete
extension MessageControllerTests {
    func testDeleteMessageSuceed() async throws {
        let admin = try await User.create(username: expectedSenderUsername, on: app.db)
        let token = try await Token.create(for: admin, on: app.db)
        let receiver = try await User.create(username: expectedSenderUsername, on: app.db)
        // Create message for test
        let message = try await Message.create(title: expectedTitle, content: expectedContent,
                                               sender: admin, receiver: receiver, on: app.db)
        
        let messageID = try message.requireID()
        try app.test(.DELETE, "api/messages/\(messageID)") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
        }
    }
    
    func testDeleteMessageWithoutAdminPermissionFails() async throws {
        let sender = try await User.create(username: expectedSenderUsername, userType: .client, on: app.db)
        let token = try await Token.create(for: sender, on: app.db)
        let receiver = try await User.create(username: expectedSenderUsername, on: app.db)
        // Create message for test
        let message = try await Message.create(title: expectedTitle, content: expectedContent,
                                               sender: sender, receiver: receiver, on: app.db)
        
        let messageID = try message.requireID()
        try app.test(.DELETE, "api/messages/\(messageID)") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.userShouldBeAdmin"))
        }
    }
    
    func testDeleteInexistantMessageFails() async throws {
        let sender = try await User.create(username: expectedSenderUsername, on: app.db)
        let token = try await Token.create(for: sender, on: app.db)
        let uuid = "1234"
        
        try app.test(.DELETE, "api/messages/\(uuid)") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.message"))
        }
    }
}

// MARK: - Remove All
extension MessageControllerTests {
    func testRemoveAllMessagesSucceed() async throws {
        let admin = try await User.create(username: expectedSenderUsername, on: app.db)
        let token = try await Token.create(for: admin, on: app.db)
        
        try app.test(.DELETE, "api/messages/all") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
        }
    }
    
    func testRemoveAllMessagesWithoutAdminPermissionFails() async throws {
        let sender = try await User.create(username: expectedSenderUsername, userType: .employee, on: app.db)
        let token = try await Token.create(for: sender, on: app.db)
        
        try app.test(.DELETE, "api/messages/all") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.userShouldBeAdmin"))
        }
    }
}
