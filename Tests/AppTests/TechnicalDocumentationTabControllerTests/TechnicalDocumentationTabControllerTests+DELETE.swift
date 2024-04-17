//
//  TechnicalDocumentationTabControllerTests+DELETE.swift
//
//
//  Created by Raphaël Payet on 17/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Remove
extension TechnicalDocumentationTabControllerTests {
    func testRemoveTabSucceed() async throws {
        try await TechnicalDocumentationTab.deleteAll(on: app.db)
        let tab = try await TechnicalDocumentationTab.create(name: expectedName, area: expectedArea, on: app.db)
        let tabID = try tab.requireID()
        
        let user = try await User.create(username: expectedAdminUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        let path = "\(baseRoute)/\(tabID)"
        try await app.test(.DELETE, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
            let tabs = try await TechnicalDocumentationTab.query(on: app.db).all()
            XCTAssertEqual(tabs.count, 0)
        }
    }
    
    func testRemoveInexistantTabFails() async throws {
        try await TechnicalDocumentationTab.deleteAll(on: app.db)
        
        let user = try await User.create(username: expectedAdminUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        let path = "\(baseRoute)/1234"
        try app.test(.DELETE, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.technicalTab"))
        }
    }
}
