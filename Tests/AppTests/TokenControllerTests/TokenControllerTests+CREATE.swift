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
    func test_Login_Success() async throws {
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

    func test_Login_WithRefreshToken_Success() async throws {
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

    func test_Login_WithoutUser_Fails() async throws {
        let path = "\(baseRoute)/login"
        try app.test(.POST, path, beforeRequest: { req in
            req.headers.basicAuthorization = BasicAuthorization(username: "wrongUser", password: "wrongPass")
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        })
    }


    func test_Login_WithBlockedUser_Fails() async throws {
        let user = try await User.create(username: expectedUsername, password: expectedPassword, on: app.db)
        user.isBlocked = true
        try await user.update(on: app.db)
        
        let path = "\(baseRoute)/login"
        try app.test(.POST, path, beforeRequest: { req in
            req.headers.basicAuthorization = BasicAuthorization(username: expectedUsername, password: expectedPassword)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .forbidden)
            XCTAssertTrue(res.body.string.contains("forbidden.accountBlocked"))
        })
    }

    func test_Login_WithConnectionBlockedUser_Fails() async throws {
        let user = try await User.create(username: expectedUsername, password: expectedPassword, on: app.db)
        user.isConnectionBlocked = true
        try await user.update(on: app.db)

        let path = "\(baseRoute)/login"
        try app.test(.POST, path, beforeRequest: { req in
            req.headers.basicAuthorization = BasicAuthorization(username: expectedUsername, password: expectedPassword)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .forbidden)
            XCTAssertTrue(res.body.string.contains("forbidden.connectionBlocked"))
        })
    }
    
    func test_Login_WithWrongPassword_Fails() async throws {
        let _ = try await User.create(username: expectedUsername, password: expectedPassword, on: app.db)
        
        try await app.test(.POST, "\(baseRoute)/login", beforeRequest: { req in
            req.headers.basicAuthorization = BasicAuthorization(username: expectedUsername, password: "wrongPassword")
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.login.invalidCredentials"))
            do {
                let users = try await User.query(on: app.db).all()
                XCTAssertEqual(users[0].connectionFailedAttempts, 1)
            } catch {}
        })
    }
}
