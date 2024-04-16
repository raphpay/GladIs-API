//
//  ModuleControllerTests+UPDATE.swift
//
//
//  Created by Raphaël Payet on 16/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Update
extension ModuleControllerTests {
    func testUpdateModuleNameSuceed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        // Clean before testing
        try await Module.deleteAll(on: app.db)
        
        // Create module for tests
        let module = try await Module.create(name: expectedModuleName, index: expectedIndex, on: app.db)
        let updatedModuleName = "updatedModuleName"
        let updatedModuleInput = Module.Input(name: updatedModuleName, index: expectedIndex)
        
        let moduleID = try module.requireID()
        let path = "api/modules/\(moduleID)"
        
        try await app.test(.PUT, path, beforeRequest: { req in
            try req.content.encode(updatedModuleInput)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let module = try res.content.decode(Module.self)
            XCTAssertEqual(module.name, updatedModuleName)
            XCTAssertEqual(module.index, expectedIndex)
            // Verify the event is updated in the database
            let fetchedModule = try await Module.find(module.id, on: app.db)
            XCTAssertEqual(fetchedModule?.name, updatedModuleName)
        })
    }
    
    func testUpdateModuleIndexSuceed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        // Clean before testing
        try await Module.deleteAll(on: app.db)
        
        // Create module for tests
        let module = try await Module.create(name: expectedModuleName, index: expectedIndex, on: app.db)
        let updatedModuleIndex = expectedIndex + 1
        let updatedModuleInput = Module.Input(name: expectedModuleName, index: updatedModuleIndex)
        
        let moduleID = try module.requireID()
        let path = "api/modules/\(moduleID)"
        try await app.test(.PUT, path, beforeRequest: { req in
            try req.content.encode(updatedModuleInput)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let module = try res.content.decode(Module.self)
            XCTAssertEqual(module.name, expectedModuleName)
            XCTAssertEqual(module.index, updatedModuleIndex)
            // Verify the event is updated in the database
            let fetchedModule = try await Module.find(module.id, on: app.db)
            XCTAssertEqual(fetchedModule?.index, updatedModuleIndex)
        })
    }
    
    func testUpdateModuleSuceed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        // Clean before testing
        try await Module.deleteAll(on: app.db)
        
        // Create module for tests
        let module = try await Module.create(name: expectedModuleName, index: expectedIndex, on: app.db)
        let updatedModuleName = "updatedModuleName"
        let updatedModuleIndex = expectedIndex + 1
        let updatedModuleInput = Module.Input(name: updatedModuleName, index: updatedModuleIndex)
        
        let moduleID = try module.requireID()
        let path = "api/modules/\(moduleID)"
        try await app.test(.PUT, path, beforeRequest: { req in
            try req.content.encode(updatedModuleInput)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let module = try res.content.decode(Module.self)
            XCTAssertEqual(module.name, updatedModuleName)
            XCTAssertEqual(module.index, updatedModuleIndex)
            // Verify the event is updated in the database
            let fetchedModule = try await Module.find(module.id, on: app.db)
            XCTAssertEqual(fetchedModule?.name, updatedModuleName)
            XCTAssertEqual(fetchedModule?.index, updatedModuleIndex)
        })
    }
    
    func testUpdateInexistantModuleFails() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        // Clean before testing
        try await Module.deleteAll(on: app.db)
        
        let updatedModuleName = "updatedModuleName"
        let updatedModuleIndex = expectedIndex + 1
        let updatedModuleInput = Module.Input(name: updatedModuleName, index: updatedModuleIndex)
        
        let path = "api/modules/12345"
        try app.test(.PUT, path, beforeRequest: { req in
            try req.content.encode(updatedModuleInput)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.module"))
        })
    }
}
