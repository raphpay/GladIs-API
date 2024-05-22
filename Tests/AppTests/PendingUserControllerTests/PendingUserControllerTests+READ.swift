//
//  PendingUserControllerTests+READ.swift
//
//
//  Created by Raphaël Payet on 16/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Get All
extension PendingUserControllerTests {
    func testGetAllPendingUserSucceed() async throws {
        // Clear
        try await PendingUser.deleteAll(on: app.db)
        
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let pendingUser = try await PendingUser.create(firstName: expectedFirstName, lastName: expectedLastName,
                                                       phoneNumber: expectedPhoneNumber, companyName: expectedCompanyName,
                                                       email: expectedEmail, products: expectedProducts, numberOfEmployees: expectedNumberOfEmployees, numberOfUsers: expectedNumberOfUsers, salesAmount: expectedSalesAmount, on: app.db)
        
    
        try app.test(.GET, baseRoute, beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let users = try res.content.decode([PendingUser].self)
            XCTAssertEqual(users.count, 1)
            XCTAssertEqual(users[0].lastName, expectedLastName)
            let pendingUserID = try pendingUser.requireID()
            XCTAssertEqual(users[0].id, pendingUserID)
        })
    }
    
    func testGetAllPendingUserWithoutAdminPermissionFails() async throws {
        // Clear
        try await PendingUser.deleteAll(on: app.db)
        
        let user = try await User.create(username: expectedUsername, userType: .client, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let pendingUser = try await PendingUser.create(firstName: expectedFirstName, lastName: expectedLastName,
                                                       phoneNumber: expectedPhoneNumber, companyName: expectedCompanyName,
                                                       email: expectedEmail, products: expectedProducts, numberOfEmployees: expectedNumberOfEmployees, numberOfUsers: expectedNumberOfUsers, salesAmount: expectedSalesAmount, on: app.db)
        
    
        try app.test(.GET, baseRoute, beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .forbidden)
            XCTAssertTrue(res.body.string.contains("forbidden.userShouldBeAdmin"))
        })
    }
}

// MARK: - Get Modules
extension PendingUserControllerTests {
    func testGetModulesSucceed() async throws {
        let user = try await User.create(username: expectedUsername, userType: .client, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let pendingUser = try await PendingUser.create(firstName: expectedFirstName, lastName: expectedLastName,
                                                       phoneNumber: expectedPhoneNumber, companyName: expectedCompanyName,
                                                       email: expectedEmail, products: expectedProducts, numberOfEmployees: expectedNumberOfEmployees, numberOfUsers: expectedNumberOfUsers, salesAmount: expectedSalesAmount, on: app.db)
        let pendingUserID = try pendingUser.requireID()
        let moduleInput = Module.Input(name: expectedModuleName, index: expectedModuleIndex)
        
        let path = "\(baseRoute)/\(pendingUserID)/modules"
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(moduleInput)
        }

        try app.test(.GET, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in 
            XCTAssertEqual(res.status, .ok)
            let modules = try res.content.decode([Module].self)
            XCTAssertEqual(modules.count, 1)
            XCTAssertEqual(modules[0].name, expectedModuleName)
            XCTAssertEqual(modules[0].index, expectedModuleIndex)
        }
    }
    
    func testGetModulesWithInexistantPendingUserFails() async throws {
        let user = try await User.create(username: expectedUsername, userType: .client, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
       
        try app.test(.GET, "\(baseRoute)/12345/modules") { req in 
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.pendingUser"))
        }
    }
}
