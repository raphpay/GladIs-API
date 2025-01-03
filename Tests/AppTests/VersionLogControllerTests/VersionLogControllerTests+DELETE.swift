//
//  VersionLogControllerTests+DELETE.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 03/01/2025.
//

@testable import App
import XCTVapor
import Fluent
import Vapor

// MARK: - Delete
extension VersionLogControllerTests {
    func test_Delete_Succeed() async throws {
        let _ = try await VersionLogControllerTests().createExpectedVersionLog(on: app.db)
        try await app.test(.DELETE, "\(baseURL)/all", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .noContent)
        })
    }
    
    func test_Delete_WithUnauthorizedRole_Fails() async throws {
        let _ = try await VersionLogControllerTests().createExpectedVersionLog(on: app.db)
        
        let unauthorizedUser = try await UserControllerTests().createExpectedUser(userType: .client, on: app.db)
        let unauthorizedToken = try await Token.create(for: unauthorizedUser, on: app.db)
        
        try await app.test(.DELETE, "\(baseURL)/all", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: unauthorizedToken.value)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.role"))
        })
    }
}
