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

// MARK: - Add module
extension PendingUserControllerTests {
    func testAddModuleSucceed() async throws  {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let pendingUser = try await PendingUser.create(firstName: expectedFirstName, lastName: expectedLastName,
                                                       phoneNumber: expectedPhoneNumber, companyName: expectedCompanyName,
                                                       email: expectedEmail, products: expectedProducts, numberOfEmployees: expectedNumberOfEmployees, numberOfUsers: expectedNumberOfUsers, salesAmount: expectedSalesAmount, on: app.db)
        let pendingUserID = try pendingUser.requireID()
        let path = "\(baseRoute)/\(pendingUserID)/modules"
        let moduleInput = Module.Input(name: expectedModuleName, index: expectedModuleIndex)

        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(moduleInput)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let updatedUser = try res.content.decode(PendingUser.self)
            XCTAssertEqual(updatedUser.modules?.count, 1)
            XCTAssertEqual(updatedUser.modules?[0].name, expectedModuleName)
            XCTAssertEqual(updatedUser.modules?[0].index, expectedModuleIndex)
        }
    }

    func testAddModuleToInexistantPendingUserFails() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)

        let path = "\(baseRoute)/123456/modules"
        let moduleInput = Module.Input(name: expectedModuleName, index: expectedModuleIndex)

        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(moduleInput)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.pendingUser"))
        }
    }

    func testAddModuleThatIsAlreadyAddedFails() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let pendingUser = try await PendingUser.create(firstName: expectedFirstName, lastName: expectedLastName,
                                                       phoneNumber: expectedPhoneNumber, companyName: expectedCompanyName,
                                                       email: expectedEmail, products: expectedProducts, numberOfEmployees: expectedNumberOfEmployees, numberOfUsers: expectedNumberOfUsers, salesAmount: expectedSalesAmount, on: app.db)
        let pendingUserID = try pendingUser.requireID()
        let path = "\(baseRoute)/\(pendingUserID)/modules"
        let moduleInput = Module.Input(name: expectedModuleName, index: expectedModuleIndex)

        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(moduleInput)
        }

        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(moduleInput)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.moduleAlreadyExists"))
        }
    }
}
