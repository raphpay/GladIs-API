//
//  PasswordResetTokenControllerTests+READ.swift
//
//
//  Created by Raphaël Payet on 15/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Get all
extension PasswordResetTokenControllerTests {
    func test_GetAllResetTokens_Succeed() async throws {
        let user = try await User.create(username: expectedUsername, email: expectedEmail, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let _ = try await PasswordResetToken.create(for: user, on: app.db)
        
        try app.test(.GET, baseURL) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let tokens = try res.content.decode([PasswordResetToken.Public].self)
            XCTAssertEqual(tokens.count, 1)
            XCTAssertEqual(tokens[0].userEmail, expectedEmail)
        }
    }
}
