//
//  TechnicalDocumentationTabControllerTests+CREATE.swift
//
//
//  Created by Raphaël Payet on 17/04/2024.
//


@testable import App
import XCTVapor

// MARK: - Create
extension TechnicalDocumentationTabControllerTests {
    func testCreateTabSucceed() async throws {
        let user = try await User.create(username: expectedAdminUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        let tabInput = TechnicalDocumentationTab.Input(name: expectedName, area: expectedArea)
        
        try app.test(.POST, baseRoute) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(tabInput)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let createdTab = try res.content.decode(TechnicalDocumentationTab.self)
            XCTAssertEqual(createdTab.name, expectedName)
            XCTAssertEqual(createdTab.area, expectedArea)
        }
    }
    
    func testCreateTabWithoutAdminPermissionFails() async throws {
        let user = try await User.create(username: expectedAdminUsername, userType: .client, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        let tabInput = TechnicalDocumentationTab.Input(name: expectedName, area: expectedArea)
        
        try app.test(.POST, baseRoute) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(tabInput)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .forbidden)
            XCTAssertTrue(res.body.string.contains("forbidden.userShouldBeAdmin"))
        }
    }
}
