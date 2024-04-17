//
//  TokenControllerTests+DELETE.swift
//
//
//  Created by Raphaël Payet on 17/04/2024.
//


@testable import App
import XCTVapor

// MARK: - Logout
extension TokenControllerTests {
    func testLogoutSucceed() async throws {
        try await Token.deleteAll(on: app.db)
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let tokenID = try token.requireID()
        let path = "\(baseRoute)/\(tokenID)"
        
        try await app.test(.DELETE, path) { res in
            XCTAssertEqual(res.status, .noContent)
            let tokens = try await Token.query(on: app.db).all()
            XCTAssertEqual(tokens.count, 0)
        }
    }
    
    func testLogoutWithInexistantTokenFails() async throws {
        try await Token.deleteAll(on: app.db)
        let path = "\(baseRoute)/123456"
        
        try await app.test(.DELETE, path) { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.token"))
            let tokens = try await Token.query(on: app.db).all()
            XCTAssertEqual(tokens.count, 0)
        }
    }
}


// MARK: - Remove All
extension TokenControllerTests {
    func testRemoveAllSucceed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        let path = "\(baseRoute)/all"
        try app.test(.DELETE, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
        }
    }
    
    func testRemoveAllWithoutAdminPermissionFails() async throws {
        let user = try await User.create(username: expectedUsername, userType: .client, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        let path = "\(baseRoute)/all"
        try app.test(.DELETE, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .forbidden)
            XCTAssertTrue(res.body.string.contains("forbidden.userShouldBeAdmin"))
        }
    }
}
