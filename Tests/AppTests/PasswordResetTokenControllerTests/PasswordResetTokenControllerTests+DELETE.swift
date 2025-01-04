//
//  PasswordResetTokenControllerTests+DELETE.swift
//
//
//  Created by Raphaël Payet on 15/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Remove
extension PasswordResetTokenControllerTests {
    func test_RemoveToken_Succeed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let resetToken = try await PasswordResetToken.create(for: user, on: app.db)
        
        let resetTokenID = try resetToken.requireID()
        let path = "api/passwordResetTokens/\(resetTokenID)"
        try app.test(.DELETE, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
        }
    }
    
    func test_RemoveInexistantToken_Fails() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        let path = "api/passwordResetTokens/12345"
        try app.test(.DELETE, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.passwordResetToken"))
        }
    }
}

// MARK: - Remove All
extension PasswordResetTokenControllerTests {
    func test_RemoveAllResetTokens_Succeed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        try app.test(.DELETE, "api/passwordResetTokens") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
        }
    }
}
