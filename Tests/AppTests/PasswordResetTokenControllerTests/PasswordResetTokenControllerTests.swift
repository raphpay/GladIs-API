//
//  PasswordResetControllerTests.swift
//
//
//  Created by Raphaël Payet on 15/04/2024.
//

@testable import App
import XCTVapor

final class PasswordResetControllerTests: XCTestCase {
    
    var app: Application!
    
    override func setUp() async throws {
        try await super.setUp()
        app = Application(.testing)
        try! await configure(app)
    }
    
    override func tearDown() async throws {
        try await User.deleteAll(on: app.db)
        try await PasswordResetToken.query(on: app.db).all().delete(force: true, on: app.db)
        app.shutdown()
        try await super.tearDown()
    }
    
    // Expected Properties
    let expectedUsername = "expectedUsername"
    let expectedEmail = "expectedEmail@test.com"
    let newPassword = "testPassword1("
}
