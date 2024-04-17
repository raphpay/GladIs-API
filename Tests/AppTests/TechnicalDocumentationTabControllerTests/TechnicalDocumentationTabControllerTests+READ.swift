//
//  TechnicalDocumentationTabControllerTests+CREATE.swift
//
//
//  Created by Raphaël Payet on 17/04/2024.
//


@testable import App
import XCTVapor

// MARK: - Get All
extension TechnicalDocumentationTabControllerTests {
    func testGetAllTabsSucceed() async throws {
        try await TechnicalDocumentationTab.deleteAll(on: app.db)
        let _ = try await TechnicalDocumentationTab.create(name: expectedName, area: expectedArea, on: app.db)
        let user = try await User.create(username: expectedAdminUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        try app.test(.GET, baseRoute) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let tabs = try res.content.decode([TechnicalDocumentationTab].self)
            XCTAssertEqual(tabs.count, 1)
            XCTAssertEqual(tabs[0].name, expectedName)
        }
    }
    
    
    func testGetAllTabsWithEmptyTabsSucceedWithEmptyResponse() async throws {
        try await TechnicalDocumentationTab.deleteAll(on: app.db)
        let user = try await User.create(username: expectedAdminUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        try app.test(.GET, baseRoute) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let tabs = try res.content.decode([TechnicalDocumentationTab].self)
            XCTAssertEqual(tabs.count, 0)
        }
    }
}
