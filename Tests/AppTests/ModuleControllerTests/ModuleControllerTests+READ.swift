//
//  ModuleControllerTests+READ.swift
//
//
//  Created by Raphaël Payet on 16/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Get All
extension ModuleControllerTests {
    func testGetAllModuleSucceed() async throws {
        // Clean before testing
        try await Module.deleteAll(on: app.db)
        
        // Create module for tests
        let module = try await Module.create(name: expectedModuleName, index: expectedIndex, on: app.db)
        
        try app.test(.GET, "api/modules/", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let modules = try res.content.decode([Module].self)
            XCTAssertEqual(modules.count, 1)
            XCTAssertEqual(modules[0].name, expectedModuleName)
            XCTAssertEqual(modules[0].index, expectedIndex)
        })
    }
}

// MARK: - Get Sorted
extension ModuleControllerTests {
    func testGetSortedModuleSucceed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        // Clean before testing
        try await Module.deleteAll(on: app.db)
        
        let moduleTwoName = "Module 2"
        let moduleTwoIndex = expectedIndex + 2
        let moduleThreeName = "Module 3"
        let moduleThreeIndex = expectedIndex + 1
        
        // Create module for tests
        let moduleOne = try await Module.create(name: expectedModuleName, index: expectedIndex, on: app.db)
        let moduleTwo = try await Module.create(name: moduleTwoName, index: moduleTwoIndex, on: app.db)
        let moduleThree = try await Module.create(name: moduleThreeName, index: moduleThreeIndex, on: app.db)
        
        try app.test(.GET, "api/modules/sorted", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let modules = try res.content.decode([Module].self)
            XCTAssertEqual(modules.count, 3)
            XCTAssertEqual(modules[0].name, expectedModuleName)
            XCTAssertEqual(modules[0].index, expectedIndex)
            XCTAssertEqual(modules[1].name, moduleThreeName)
            XCTAssertEqual(modules[1].index, moduleThreeIndex)
            XCTAssertEqual(modules[2].name, moduleTwoName)
            XCTAssertEqual(modules[2].index, moduleTwoIndex)
        })
    }
}


