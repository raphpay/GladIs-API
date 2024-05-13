//
//  DocumentActivityLogControllerTests+DELETE.swift
//  
//
//  Created by Raphaël Payet on 15/04/2024.
//

@testable import App
import XCTVapor

extension DocumentActivityLogControllerTests {
    func testDeleteAllDocumentActivityLogs() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        try app.test(.DELETE, "api/documentActivityLogs") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
        }
    }

    func testDeleteAllDocumentActivityLogsWithoutPermissionFails() async throws {
        let user = try await User.create(username: expectedClientUsername, userType: .client, on: app.db)
        let token = try await Token.create(for: user, on: app.db)

        try app.test(.DELETE, "api/documentActivityLogs") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .forbidden)
            XCTAssertTrue(res.body.string.contains("forbidden.userShouldBeAdmin"))
        }
    }
}
