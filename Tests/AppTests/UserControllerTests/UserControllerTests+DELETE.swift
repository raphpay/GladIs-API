//
//  UserControllerTests+CREATE.swift
//
//
//  Created by Raphaël Payet on 17/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Remove
//tokenAuthGroup.delete(":userID", use: remove)
extension UserControllerTests {
    func testRemoveUserSucceed() async throws {
        let user = try await User.create(username: expectedAdminUsername, on: app.db)
        let userToDelete = try await User.create(username: expectedUsername, userType: .client, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        let userID = try userToDelete.requireID()
        let path = "\(baseRoute)/\(userID)"
        try await app.test(.DELETE, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
            let users = try await User.query(on: app.db).all()
            XCTAssertEqual(users.count, 1)
        }
    }
    
    func testRemoveInexistantUserFails() async throws {
        let user = try await User.create(username: expectedAdminUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        let path = "\(baseRoute)/1234"
        try app.test(.DELETE, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
}

// MARK: - Remove all
extension UserControllerTests {
    func testRemoveAllSucceed() async throws {
        let user = try await User.create(username: expectedAdminUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        let path = "\(baseRoute)/all"
        try await app.test(.DELETE, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
            let users = try await User.query(on: app.db).all()
            XCTAssertEqual(users.count, 0)
        }
    }
}
