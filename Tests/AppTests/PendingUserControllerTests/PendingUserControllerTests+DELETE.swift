//
//  PendingUserControllerTests+DELETE.swift
//
//
//  Created by Raphaël Payet on 16/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Remove
extension PendingUserControllerTests {
    func testRemovePendingUserSucceed() async throws {
        let pendingUser = try await PendingUserControllerTests().createExpectedPendingUser(on: app.db)
        let pendingUserID = try pendingUser.requireID()
        
        try app.test(.DELETE, "\(baseRoute)/\(pendingUserID)") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
        }
    }
    
    func testRemovePendingUserWithoutAdminPermissionFails() async throws {
        let user = try await User.create(username: expectedUsername, userType: .client, on: app.db)
        let clientToken = try await Token.create(for: user, on: app.db)
        let pendingUser = try await PendingUserControllerTests().createExpectedPendingUser(on: app.db)
        let pendingUserID = try pendingUser.requireID()
        
        try app.test(.DELETE, "\(baseRoute)/\(pendingUserID)") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: clientToken.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .forbidden)
            XCTAssertTrue(res.body.string.contains("forbidden.userShouldBeAdmin"))
        }
    }
    
    func testRemoveInexistantPendingUserFails() async throws {
        try app.test(.DELETE, "\(baseRoute)/12345") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.pendingUser"))
        }
    }
}
