//
//  MessageControllerTests+CREATE.swift
//
//
//  Created by Raphaël Payet on 16/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Create
extension MessageControllerTests {
    func testCreateMessageSuccess() async throws {
        let sender = try await User.create(username: expectedSenderUsername, on: app.db)
        let token = try await Token.create(for: sender, on: app.db)
        let receiver = try await User.create(username: expectedReceiverUsername, on: app.db)
        let messageInput = Message.Input(title: expectedTitle, content: expectedContent,
                                    senderID: try sender.requireID(), senderMail: sender.email,
                                    receiverID: try receiver.requireID(), receiverMail: receiver.email)
        
        try app.test(.POST, "api/messages") { req in
            try req.content.encode(messageInput)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let message = try res.content.decode(Message.self)
            XCTAssertEqual(message.title, expectedTitle)
            XCTAssertEqual(message.content, expectedContent)
            XCTAssertEqual(message.$sender.id, try sender.requireID())
            XCTAssertEqual(message.$receiver.id, try receiver.requireID())
        }
    }
    
    func testCreateMessageWithSameSenderAndReceiverFails() async throws {
        let sender = try await User.create(username: expectedSenderUsername, on: app.db)
        let token = try await Token.create(for: sender, on: app.db)
        let messageInput = Message.Input(title: expectedTitle, content: expectedContent,
                                    senderID: try sender.requireID(), senderMail: sender.email,
                                    receiverID: try sender.requireID(), receiverMail: sender.email)
        
        try app.test(.POST, "api/messages") { req in
            try req.content.encode(messageInput)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.message.senderAndReceiverSame"))
        }
    }
}
