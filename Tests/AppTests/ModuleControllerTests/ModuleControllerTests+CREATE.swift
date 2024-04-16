//
//  ModuleControllerTests+CREATE.swift
//
//
//  Created by Raphaël Payet on 16/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Create
extension ModuleControllerTests {
    func testCreateModuleSuceed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        // Clean all modules
        try await Module.deleteAll(on: app.db)
        
        let moduleInput = Module.Input(name: expectedModuleName, index: expectedIndex)
        
        try app.test(.POST, "api/modules") { req in
            try req.content.encode(moduleInput)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let module = try res.content.decode(Module.self)
            XCTAssertEqual(module.name, moduleInput.name)
            XCTAssertEqual(module.index, moduleInput.index)
        }
    }
    
    func testCreateModuleWithoutAdminPermissionFails() async throws {
        let user = try await User.create(username: expectedUsername, userType: .client, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let moduleInput = Module.Input(name: expectedModuleName, index: expectedIndex)
        
        try app.test(.POST, "api/modules") { req in
            try req.content.encode(moduleInput)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .forbidden)
            XCTAssertTrue(res.body.string.contains("forbidden.userShouldBeAdmin"))
        }
    }
    
    func testCreateModuleWithSameIndexFails() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        // Clean all modules
        try await Module.deleteAll(on: app.db)
        
        let moduleInputOne = try await Module.create(name: expectedModuleName, index: expectedIndex, on: app.db)
        let moduleInputTwo = Module.Input(name: "module2", index: expectedIndex)
        
        try app.test(.POST, "api/modules") { req in
            try req.content.encode(moduleInputTwo)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("Module with index \(expectedIndex) already exists"))
        }
    }
}
