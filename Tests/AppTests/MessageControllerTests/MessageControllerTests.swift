//
//  MessageControllerTests.swift
//
//
//  Created by Raphaël Payet on 15/04/2024.
//

@testable import App
import XCTVapor

final class MessageControllerTests: XCTestCase {
    
    var app: Application!
    // Expected Properties
    let expectedTitle = "Message Title"
    let expectedContent = "Message content under 300"
    let exceedingContent = """
a long message with more than 300 characters, a long message with more than 300 characters, a long message with more than 300 characters, a long message with more than 300 characters, a long message with more than 300 characters, a long message with more than 300 characters, a long message with more than 300 characters
"""
    let expectedSenderUsername = "expectedSenderUsername"
    let expectedReceiverUsername = "expectedReceiverUsername"
    
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
