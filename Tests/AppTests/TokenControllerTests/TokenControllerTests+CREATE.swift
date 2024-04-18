//
//  TokenControllerTests+CREATE.swift
//
//
//  Created by Raphaël Payet on 17/04/2024.
//


@testable import App
import XCTVapor

// MARK: - Login
extension TokenControllerTests {
    func testLoginSuccessNewToken() async throws {
        try await User.deleteAll(on: app.db)
        let _ = try await User.create(username: expectedUsername, password: expectedPassword, on: app.db)
        
        let path = "\(baseRoute)/login"
        try await app.test(.POST, path, beforeRequest: { req in
            req.headers.basicAuthorization = BasicAuthorization(username: expectedUsername, password: expectedPassword)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let token = try res.content.decode(Token.self)
            XCTAssertNotNil(token.value)
            let savedToken = try await Token.find(token.id, on: app.db)
            XCTAssertEqual(savedToken?.value, token.value)
        })
    }

    func testLoginSuccessTokenRefresh() async throws {
        try await User.deleteAll(on: app.db)
        let user = try await User.create(username: expectedUsername, password: expectedPassword, on: app.db)
        let existingToken = try await Token.create(for: user, on: app.db)

        let path = "\(baseRoute)/login"
        try await app.test(.POST, path, beforeRequest: { req in
            req.headers.basicAuthorization = BasicAuthorization(username: expectedUsername, password: expectedPassword)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let token = try res.content.decode(Token.self)
            XCTAssertNotEqual(token.value, existingToken.value)
            // Verify token is updated in the database
            let updatedToken = try await Token.find(token.id, on: app.db)
            XCTAssertEqual(updatedToken?.value, token.value)
        })
    }

    func testLoginWithoutUserFails() async throws {
        let path = "\(baseRoute)/login"
        try app.test(.POST, path, beforeRequest: { req in
            req.headers.basicAuthorization = BasicAuthorization(username: "wrongUser", password: "wrongPass")
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.login"))
        })
    }


    func testLoginWithBlockedUserFails() async throws {
        try await User.deleteAll(on: app.db)
        let user = try await User.create(username: expectedUsername, password: expectedPassword, on: app.db)
        user.isBlocked = true
        try await user.update(on: app.db)
        
        let path = "\(baseRoute)/login"
        try app.test(.POST, path, beforeRequest: { req in
            req.headers.basicAuthorization = BasicAuthorization(username: expectedUsername, password: expectedPassword)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.login.account.blocked"))
        })
    }
}
