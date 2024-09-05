//
//  PendingUserControllerTests+UPDATE.swift
//
//
//  Created by Raphaël Payet on 16/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Update Status
extension PendingUserControllerTests {
    func testUpdateStatusSucceed() async throws {
        let pendingUser = try await PendingUserControllerTests().createExpectedPendingUser(on: app.db)
        let pendingUserID = try pendingUser.requireID()
        
        let newStatus = PendingUser.StatusInput(type: .accepted)
        
        try app.test(.PUT, "\(baseRoute)/\(pendingUserID)/status") { req in
            try req.content.encode(newStatus)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let updatedUser = try res.content.decode(PendingUser.self)
            XCTAssertEqual(updatedUser.status, newStatus.type)
        }
    }
}

// MARK: - Update modules
extension PendingUserControllerTests {
    func testAddPendingUserModulesSucceed() async throws {
        let pendingUser = try await PendingUserControllerTests().createExpectedPendingUser(on: app.db)
        let pendingUserID = try pendingUser.requireID()
        
        let moduleInputs = [Module.Input(name: expectedModuleName, index: expectedModuleIndex),
                            Module.Input(name: "\(expectedModuleName)2", index: expectedModuleIndex + 1)]
        
        try app.test(.PUT, "\(baseRoute)/\(pendingUserID)/modules") { req in
            try req.content.encode(moduleInputs)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let updatedUser = try res.content.decode(PendingUser.self)
            XCTAssertEqual(updatedUser.modules?.count, 2)
            XCTAssertEqual(updatedUser.modules?[0].name, expectedModuleName)
            XCTAssertEqual(updatedUser.modules?[0].index, expectedModuleIndex)
            XCTAssertEqual(updatedUser.modules?[1].name, "\(expectedModuleName)2")
            XCTAssertEqual(updatedUser.modules?[1].index, expectedModuleIndex + 1)
        }
    }

    func testRemovePendingUsersModulesSucceed() async throws {
        let pendingUser = try await PendingUserControllerTests().createExpectedPendingUser(on: app.db)
        let pendingUserID = try pendingUser.requireID()
        
        let moduleOne = Module(name: expectedModuleName, index: expectedModuleIndex)
        let moduleTwo = Module(name: "\(expectedModuleName)2", index: expectedModuleIndex)
        try await pendingUser.addModules([moduleOne, moduleTwo], on: app.db)
        
        let moduleInputs = [Module.Input(name: moduleTwo.name, index: moduleTwo.index)]
        
        try app.test(.PUT, "\(baseRoute)/\(pendingUserID)/modules") { req in
            try req.content.encode(moduleInputs)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let updatedUser = try res.content.decode(PendingUser.self)
            XCTAssertEqual(updatedUser.modules?.count, 1)
            XCTAssertEqual(updatedUser.modules?[0].name, moduleTwo.name)
        }
    }

    func testAddPendingUsersModulesToInexistantPendingUserFails() async throws {
        try app.test(.PUT, "\(baseRoute)/123456/modules") { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.pendingUser"))
        }
    }

    func testRemovePendingUsersModulesToInexistantPendingUserFails() async throws {
        let pendingUser = try await PendingUserControllerTests().createExpectedPendingUser(on: app.db)
        
        let moduleOne = Module(name: expectedModuleName, index: expectedModuleIndex)
        let moduleTwo = Module(name: "\(expectedModuleName)2", index: expectedModuleIndex)
        try await pendingUser.addModules([moduleOne, moduleTwo], on: app.db)
        
        let moduleInputs = [Module.Input(name: moduleTwo.name, index: moduleTwo.index)]
        
        try app.test(.PUT, "\(baseRoute)/12345/modules") { req in
            try req.content.encode(moduleInputs)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.pendingUser"))
        }
    }
}
