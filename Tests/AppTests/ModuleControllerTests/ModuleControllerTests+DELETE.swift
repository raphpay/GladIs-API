//
//  ModuleControllerTests+DELETE.swift
//
//
//  Created by Raphaël Payet on 16/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Remove
extension ModuleControllerTests {
    func testRemoveModuleSucceed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        // Create module for tests
        let module = try await Module.create(name: expectedModuleName, index: expectedIndex, on: app.db)
        
        let moduleID = try module.requireID()
        
        try app.test(.DELETE, "api/modules/\(moduleID)") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
        }
    }
    
    func testRemoveInexistantModuleFails() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        try app.test(.DELETE, "api/modules/12345") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.module"))
        }
    }
}
