//
//  PasswordResetControllerTests+CREATE.swift
//
//
//  Created by Raphaël Payet on 15/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Request Password Reset
extension PasswordResetControllerTests {
    func test_RequestPasswordReset_Succeed() async throws {
        let userEmailInput = User.EmailInput(email: expectedEmail)
        let _ = try await User.create(username: expectedUsername, email: expectedEmail, on: app.db)
        
        try await app.test(.POST, "api/passwordResetTokens/request") { req in
            try req.content.encode(userEmailInput)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let token = try await PasswordResetToken.query(on: app.db).first()
            XCTAssertNotNil(token)
            XCTAssertEqual(token?.userEmail, expectedEmail)
        }
    }
    
    func test_RequestPasswordWithInexistantUser_Fails() async throws {
        // Clean befoire testing
        try await User.deleteAll(on: app.db)
        
        let userEmailInput = User.EmailInput(email: expectedEmail)
        
        try app.test(.POST, "api/passwordResetTokens/request") { req in
            try req.content.encode(userEmailInput)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
}

// MARK: - Reset
extension PasswordResetControllerTests {
    func test_ResetPassword_Succeed() async throws {
        let user = try await User.create(username: expectedUsername, email: expectedEmail, on: app.db)
        let resetToken = try await PasswordResetToken.create(for: user, on: app.db)
        let input = ResetPasswordRequest(token: resetToken.token, newPassword: newPassword)
        
        try await app.test(.POST, "api/passwordResetTokens/reset") { req in
            try req.content.encode(input)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let tokens = try await PasswordResetToken.query(on: app.db).all()
            XCTAssertEqual(tokens.count, 0)
        }
    }
    
    func test_ResetPasswordWithInexistantToken_Fails() async throws {
        let input = ResetPasswordRequest(token: "123456", newPassword: newPassword)
        
        try app.test(.POST, "api/passwordResetTokens/reset") { req in
            try req.content.encode(input)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.resetToken"))
        }
    }
    
    func test_ResetPasswordWithExpiredDate_Fails() async throws {
        let user = try await User.create(username: expectedUsername, email: expectedEmail, on: app.db)
        let resetToken = try await PasswordResetToken.create(for: user, expiresAt: Date().addingTimeInterval(-3600 * 2), on: app.db)
        
        let input = ResetPasswordRequest(token: resetToken.token, newPassword: newPassword)
        
        try app.test(.POST, "api/passwordResetTokens/reset") { req in
            try req.content.encode(input)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.tokenExpired"))
        }
    }
    
    // MARK: - Password
    func test_ResetPasswordWithInvalidPasswordLength_Fails() async throws {
        let user = try await User.create(username: expectedUsername, email: expectedEmail, on: app.db)
        let resetToken = try await PasswordResetToken.create(for: user, expiresAt: Date().addingTimeInterval(3600 * 2), on: app.db)
        let input = ResetPasswordRequest(token: resetToken.token, newPassword: "n")
        
        try app.test(.POST, "api/passwordResetTokens/reset") { req in
            try req.content.encode(input)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.password.invalidLength"))
        }
    }
    
    func test_ResetPasswordWithMissingUppercase_Fails() async throws {
        let user = try await User.create(username: expectedUsername, email: expectedEmail, on: app.db)
        let resetToken = try await PasswordResetToken.create(for: user, expiresAt: Date().addingTimeInterval(3600 * 2), on: app.db)
        let input = ResetPasswordRequest(token: resetToken.token, newPassword: "nononononono")
        
        try app.test(.POST, "api/passwordResetTokens/reset") { req in
            try req.content.encode(input)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.password.missingUppercase"))
        }
    }
    
    func test_ResetPasswordWithMissingDigit_Fails() async throws {
        let user = try await User.create(username: expectedUsername, email: expectedEmail, on: app.db)
        let resetToken = try await PasswordResetToken.create(for: user, expiresAt: Date().addingTimeInterval(3600 * 2), on: app.db)
        let input = ResetPasswordRequest(token: resetToken.token, newPassword: "Nononononono")
        
        try app.test(.POST, "api/passwordResetTokens/reset") { req in
            try req.content.encode(input)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.password.missingDigit"))
        }
    }
    
    func test_ResetPasswordWithMissingSpecialCharacter_Fails() async throws {
        let user = try await User.create(username: expectedUsername, email: expectedEmail, on: app.db)
        let resetToken = try await PasswordResetToken.create(for: user, expiresAt: Date().addingTimeInterval(3600 * 2), on: app.db)
        let input = ResetPasswordRequest(token: resetToken.token, newPassword: "Nononononono1")
        
        try app.test(.POST, "api/passwordResetTokens/reset") { req in
            try req.content.encode(input)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.password.missingSpecialCharacter"))
        }
    }
}
