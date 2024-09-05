//
//  UserControllerTests+DELETE.swift
//
//
//  Created by Raphaël Payet on 17/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Remove
extension UserControllerTests {
    func testRemoveUserSucceed() async throws {
        let userToDelete = try await User.create(username: expectedUsername, userType: .client, on: app.db)
        let userID = try userToDelete.requireID()
        
        try await app.test(.DELETE, "\(baseRoute)/\(userID)") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
            let users = try await User.query(on: app.db).all()
            XCTAssertEqual(users.count, 1)
            XCTAssertEqual(users[0].username, expectedAdminUsername)
        }
    }
    
    func testRemoveWithIncorrectUserIDFails() async throws {
        try app.test(.DELETE, "\(baseRoute)/1234") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingOrIncorrectUserID"))
        }
    }
    
    func testRemoveWithInexistantUserFails() async throws {
        let falseUserID = UUID()
        
        try app.test(.DELETE, "\(baseRoute)/\(falseUserID)") { req in
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
        try await app.test(.DELETE, "\(baseRoute)/all") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
            let users = try await User.query(on: app.db).all()
            XCTAssertEqual(users.count, 0)
        }
    }
}
