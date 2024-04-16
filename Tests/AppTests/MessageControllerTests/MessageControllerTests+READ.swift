//
//  MessageControllerTests+CREATE.swift
//
//
//  Created by Raphaël Payet on 16/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Get All
extension MessageControllerTests {
    func testGetAllMessagesSuccess() async throws {
        let sender = try await User.create(username: expectedSenderUsername, on: app.db)
        let token = try await Token.create(for: sender, on: app.db)
        let receiver = try await User.create(username: expectedReceiverUsername, on: app.db)
        
        // Clean database before tests
        try await Message.deleteAll(on: app.db)
        
        // Create multiple messages for testing
        let messageOne = try await Message.create(title: expectedTitle, content: expectedContent,
                                               sender: sender, receiver: receiver, on: app.db)
        let messageTwo = try await Message.create(title: "Title 2", content: "Content 2",
                                               sender: sender, receiver: receiver, on: app.db)
        
        try app.test(.GET, "api/messages") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let messages = try res.content.decode([Message].self)
            XCTAssertEqual(messages.count, 2)
            XCTAssertEqual(messages[0].title, messageOne.title)
            XCTAssertEqual(messages[0].content, messageOne.content)
            XCTAssertEqual(messages[0].$sender.id, messageOne.$sender.id)
            XCTAssertEqual(messages[0].$receiver.id, messageOne.$receiver.id)
            XCTAssertEqual(messages[1].title, messageTwo.title)
        }
    }
}
