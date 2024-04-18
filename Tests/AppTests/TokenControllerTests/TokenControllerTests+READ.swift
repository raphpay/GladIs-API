//
//  TokenControllerTests+READ.swift
//
//
//  Created by Raphaël Payet on 17/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Get Token by ID
extension TokenControllerTests {
    func testGetTokenByIdSucceed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let tokenID = try token.requireID()
        
        let path = "\(baseRoute)/\(tokenID)"
        try app.test(.GET, path) { res in
            XCTAssertEqual(res.status, .ok)
            let fetchedToken = try res.content.decode(Token.self)
            XCTAssertEqual(fetchedToken.value, token.value)
        }
    }
    
    func testGetTokenByIdWithInexistantTokenFails() async throws {
        let path = "\(baseRoute)/12345"
        try app.test(.GET, path) { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.token"))
        }
    }
}

// MARK: - Get Tokens
extension TokenControllerTests {
    func testGetTokensSucceed() async throws {
        try await Token.deleteAll(on: app.db)
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        try app.test(.GET, baseRoute) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let tokens = try res.content.decode([Token].self)
            XCTAssertEqual(tokens.count, 1)
            XCTAssertEqual(tokens[0].value, token.value)
        }
    }
}
