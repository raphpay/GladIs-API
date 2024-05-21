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
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let pendingUser = try await PendingUser.create(firstName: expectedFirstName, lastName: expectedLastName,
                                                       phoneNumber: expectedPhoneNumber, companyName: expectedCompanyName,
                                                       email: expectedEmail, products: expectedProducts, numberOfEmployees: expectedNumberOfEmployees, numberOfUsers: expectedNumberOfUsers, salesAmount: expectedSalesAmount, on: app.db)
        let newStatus = PendingUser.StatusInput(type: .accepted)
        let pendingUserID = try pendingUser.requireID()
        
        let path = "\(baseRoute)/\(pendingUserID)/status"
        try app.test(.PUT, path) { req in
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
        let pendingUser = try await PendingUser.create(firstName: expectedFirstName, lastName: expectedLastName,
                                                       phoneNumber: expectedPhoneNumber, companyName: expectedCompanyName,
                                                       email: expectedEmail, products: expectedProducts, numberOfEmployees: expectedNumberOfEmployees, numberOfUsers: expectedNumberOfUsers, salesAmount: expectedSalesAmount, on: app.db)
        let pendingUserID = try pendingUser.requireID()
        let moduleToAdd = Module(name: expectedModuleName, index: expectedModuleIndex)
        let moduleToAddTwo = Module(name: "\(expectedModuleName)2", index: expectedModuleIndex + 1)
        let moduleInputs = [Module.Input(name: moduleToAdd.name, index: moduleToAdd.index),
                            Module.Input(name: moduleToAddTwo.name, index: moduleToAddTwo.index)]
        
        let path = "\(baseRoute)/\(pendingUserID)/modules"
        try app.test(.PUT, path) { req in
            try req.content.encode(moduleInputs)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let updatedUser = try res.content.decode(PendingUser.self)
            XCTAssertEqual(updatedUser.modules?.count, 2)
            XCTAssertEqual(updatedUser.modules?[0].name, moduleToAdd.name)
            XCTAssertEqual(updatedUser.modules?[1].name, moduleToAddTwo.name)
        }
    }

    func testRemovePendingUsersModulesSucceed() async throws {
        let pendingUser = try await PendingUser.create(firstName: expectedFirstName, lastName: expectedLastName,
                                                       phoneNumber: expectedPhoneNumber, companyName: expectedCompanyName,
                                                       email: expectedEmail, products: expectedProducts, numberOfEmployees: expectedNumberOfEmployees, numberOfUsers: expectedNumberOfUsers, salesAmount: expectedSalesAmount, on: app.db)
        let pendingUserID = try pendingUser.requireID()
        let moduleToAdd = Module(name: expectedModuleName, index: expectedModuleIndex)
        let moduleToAddTwo = Module(name: "\(expectedModuleName)2", index: expectedModuleIndex + 1)
        var moduleInputs = [Module.Input(name: moduleToAdd.name, index: moduleToAdd.index),
                            Module.Input(name: moduleToAddTwo.name, index: moduleToAddTwo.index)]
        
        let path = "\(baseRoute)/\(pendingUserID)/modules"
        try app.test(.PUT, path) { req in
            try req.content.encode(moduleInputs)
        }

        moduleInputs.remove(at: 0)
        try app.test(.PUT, path) { req in
            try req.content.encode(moduleInputs)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let updatedUser = try res.content.decode(PendingUser.self)
            XCTAssertEqual(updatedUser.modules?.count, 1)
            XCTAssertEqual(updatedUser.modules?[0].name, moduleToAddTwo.name)
        }
    }

    func testAddPendingUsersModulesToInexistantPendingUserFails() async throws {
        let moduleToAdd = Module(name: expectedModuleName, index: expectedModuleIndex)
        let moduleToAddTwo = Module(name: "\(expectedModuleName)2", index: expectedModuleIndex + 1)
        let moduleInputs = [Module.Input(name: moduleToAdd.name, index: moduleToAdd.index),
                            Module.Input(name: moduleToAddTwo.name, index: moduleToAddTwo.index)]
        
        let path = "\(baseRoute)/123456/modules"
        try app.test(.PUT, path) { req in
            try req.content.encode(moduleInputs)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.pendingUser"))
        }
    }

    func testRemovePendingUsersModulesToInexistantPendingUserFails() async throws {
        let pendingUser = try await PendingUser.create(firstName: expectedFirstName, lastName: expectedLastName,
                                                       phoneNumber: expectedPhoneNumber, companyName: expectedCompanyName,
                                                       email: expectedEmail, products: expectedProducts, numberOfEmployees: expectedNumberOfEmployees, numberOfUsers: expectedNumberOfUsers, salesAmount: expectedSalesAmount, on: app.db)
        let pendingUserID = try pendingUser.requireID()
        let moduleToAdd = Module(name: expectedModuleName, index: expectedModuleIndex)
        let moduleToAddTwo = Module(name: "\(expectedModuleName)2", index: expectedModuleIndex + 1)
        var moduleInputs = [Module.Input(name: moduleToAdd.name, index: moduleToAdd.index),
                            Module.Input(name: moduleToAddTwo.name, index: moduleToAddTwo.index)]
        
        let path = "\(baseRoute)/\(pendingUserID)/modules"
        try app.test(.PUT, path) { req in
            try req.content.encode(moduleInputs)
        }

        moduleInputs.remove(at: 0)
        let newPath = "\(baseRoute)/12345/modules"
        try app.test(.PUT, newPath) { req in
            try req.content.encode(moduleInputs)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.pendingUser"))
        }
    }
}