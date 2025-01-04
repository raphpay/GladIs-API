//
//  PasswordResetTokenControllerTests.swift
//
//
//  Created by Raphaël Payet on 15/04/2024.
//

@testable import App
import XCTVapor

final class PasswordResetTokenControllerTests: XCTestCase {
    
    var app: Application!
    let baseURL = "api/passwordResetTokens"
    
    override func setUp() async throws {
        try await super.setUp()
        app = Application(.testing)
        try! await configure(app)
    }
    
    override func tearDown() async throws {
        try await User.deleteAll(on: app.db)
        try await PasswordResetToken.deleteAll(on: app.db)
        app.shutdown()
        try await super.tearDown()
    }
    
    // Expected Properties
    let expectedUsername = "expectedUsername"
    let expectedEmail = "expectedEmail@test.com"
    let newPassword = "testPassword1("
}
