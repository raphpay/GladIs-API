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
    func test_Remove_Succeed() async throws {
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
    
    func test_RemoveWithInexistantToken_Fails() async throws {
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
    
    func test_Remove_WithUnauthorizedRole_Fails() async throws {
        let unauthorizedUser = try await UserControllerTests().createExpectedUser(userType: .client, on: app.db)
        let unauthorizedToken = try await Token.create(for: unauthorizedUser, on: app.db)
        
        let resetToken = try await PasswordResetToken.create(for: unauthorizedUser, on: app.db)
        let resetTokenID = try resetToken.requireID()
        
        try await app.test(.DELETE, "\(baseURL)/\(resetTokenID)", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: unauthorizedToken.value)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.role"))
        })
    }
}

// MARK: - Remove All
extension PasswordResetTokenControllerTests {
    func test_RemoveAllResetTokens_Succeed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let _ = try await PasswordResetToken.create(for: user, on: app.db)
        
        try await app.test(.DELETE, baseURL) { req async in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
            
            do {
                let tokens = try await PasswordResetToken.query(on: app.db).all()
                XCTAssertEqual(tokens.count, 0)
            } catch  { }
        }
    }
    
    func test_RemoveAll_WithUnauthorizedUser_Fails() async throws {
        let unauthorizedUser = try await UserControllerTests().createExpectedUser(userType: .client, on: app.db)
        let unauthorizedToken = try await Token.create(for: unauthorizedUser, on: app.db)
        let _ = try await PasswordResetToken.create(for: unauthorizedUser, on: app.db)
        
        try await app.test(.DELETE, baseURL, beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: unauthorizedToken.value)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.role"))
        })
    }
}
