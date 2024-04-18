//
//  PendingUserControllerTests+CREATE.swift
//  
//
//  Created by Raphaël Payet on 16/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Create
extension PendingUserControllerTests {
    func testCreatePendingUserSucceed() async throws {
        // Clear database
        try await PendingUser.deleteAll(on: app.db)
        
        let pendingUserInput = PendingUser.Input(firstName: expectedFirstName, lastName: expectedLastName,
                                                 phoneNumber: expectedPhoneNumber, companyName: expectedCompanyName,
                                                 email: expectedEmail, products: expectedProducts, numberOfEmployees: expectedNumberOfEmployees, numberOfUsers: expectedNumberOfUsers, salesAmount: expectedSalesAmount)
        
        try app.test(.POST, baseRoute) { req in
            try req.content.encode(pendingUserInput)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let createdPendingUser = try res.content.decode(PendingUser.self)
            XCTAssertEqual(createdPendingUser.firstName, expectedFirstName)
            XCTAssertEqual(createdPendingUser.lastName, expectedLastName)
            XCTAssertEqual(createdPendingUser.phoneNumber, expectedPhoneNumber)
            XCTAssertEqual(createdPendingUser.companyName, expectedCompanyName)
            XCTAssertEqual(createdPendingUser.email, expectedEmail)
            XCTAssertEqual(createdPendingUser.products, expectedProducts)
            XCTAssertEqual(createdPendingUser.numberOfEmployees, expectedNumberOfEmployees)
            XCTAssertEqual(createdPendingUser.numberOfUsers, expectedNumberOfUsers)
            XCTAssertEqual(createdPendingUser.salesAmount, expectedSalesAmount)
        }
    }
    
    func testCreatePendingUserWithAlreadyExistingMailFails() async throws {
        // Clear database
        let _ = try await PendingUser.create(firstName: expectedFirstName, lastName: expectedLastName,
                                                       phoneNumber: expectedPhoneNumber, companyName: expectedCompanyName,
                                                       email: expectedEmail, products: expectedProducts, numberOfEmployees: expectedNumberOfEmployees, numberOfUsers: expectedNumberOfUsers, salesAmount: expectedSalesAmount, on: app.db)
        let pendingUserInput = PendingUser.Input(firstName: expectedFirstName, lastName: expectedLastName,
                                                 phoneNumber: expectedPhoneNumber, companyName: expectedCompanyName,
                                                 email: expectedEmail, products: expectedProducts, numberOfEmployees: expectedNumberOfEmployees, numberOfUsers: expectedNumberOfUsers, salesAmount: expectedSalesAmount)
        
        try app.test(.POST, baseRoute) { req in
            try req.content.encode(pendingUserInput)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.emailAlreadyExists"))
        }
    }
}

// MARK: - Add module
extension PendingUserControllerTests {
    func testAddModuleToPendingUserSucceed() async throws {
        let pendingUser = try await PendingUser.create(firstName: expectedFirstName, lastName: expectedLastName,
                                                       phoneNumber: expectedPhoneNumber, companyName: expectedCompanyName,
                                                       email: expectedEmail, products: expectedProducts, numberOfEmployees: expectedNumberOfEmployees, numberOfUsers: expectedNumberOfUsers, salesAmount: expectedSalesAmount, on: app.db)
        let module = try await Module.create(name: expectedModuleName, index: expectedModuleIndex, on: app.db)
        
        let pendingUserID = try pendingUser.requireID()
        let moduleID = try module.requireID()
        try app.test(.POST, "\(baseRoute)/\(pendingUserID)/modules/\(moduleID)") { res in
            XCTAssertEqual(res.status, .ok)
            let module = try res.content.decode(Module.self)
            XCTAssertEqual(module.id, moduleID)
            XCTAssertEqual(module.name, expectedModuleName)
        }
    }
    
    func testAddModuleToPendingUserWithInexistantPendingUserFails() async throws {
        let module = try await Module.create(name: expectedModuleName, index: expectedModuleIndex, on: app.db)
        
        let moduleID = try module.requireID()
        try app.test(.POST, "\(baseRoute)/12345/modules/\(moduleID)") { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.pendingUser"))
        }
    }
    
    func testAddModuleToPendingUserWithInexistantModuleFails() async throws {
        let pendingUser = try await PendingUser.create(firstName: expectedFirstName, lastName: expectedLastName,
                                                       phoneNumber: expectedPhoneNumber, companyName: expectedCompanyName,
                                                       email: expectedEmail, products: expectedProducts, numberOfEmployees: expectedNumberOfEmployees, numberOfUsers: expectedNumberOfUsers, salesAmount: expectedSalesAmount, on: app.db)
        
        let pendingUserID = try pendingUser.requireID()
        try app.test(.POST, "\(baseRoute)/\(pendingUserID)/modules/12345") { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.module"))
        }
    }
}

// MARK: - Convert To User
extension PendingUserControllerTests {
    func testConvertToUserSuceed() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let pendingUser = try await PendingUser.create(firstName: expectedFirstName, lastName: expectedLastName,
                                                       phoneNumber: expectedPhoneNumber, companyName: expectedCompanyName,
                                                       email: expectedEmail, products: expectedProducts, numberOfEmployees: expectedNumberOfEmployees, numberOfUsers: expectedNumberOfUsers, salesAmount: expectedSalesAmount, on: app.db)
        
        let pendingUserID = try pendingUser.requireID()
        try app.test(.POST, "\(baseRoute)/\(pendingUserID)/convertToUser") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let user = try res.content.decode(User.Public.self)
            XCTAssertEqual(user.firstName, expectedFirstName)
            XCTAssertEqual(user.lastName, expectedLastName)
            XCTAssertEqual(user.email, expectedEmail)
        }
    }
 
    func testConvertToUserWithoutAdminPermissionFails() async throws {
        let user = try await User.create(username: expectedUsername, userType: .client, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        let pendingUser = try await PendingUser.create(firstName: expectedFirstName, lastName: expectedLastName,
                                                       phoneNumber: expectedPhoneNumber, companyName: expectedCompanyName,
                                                       email: expectedEmail, products: expectedProducts, numberOfEmployees: expectedNumberOfEmployees, numberOfUsers: expectedNumberOfUsers, salesAmount: expectedSalesAmount, on: app.db)
        
        let pendingUserID = try pendingUser.requireID()
        try app.test(.POST, "\(baseRoute)/\(pendingUserID)/convertToUser") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .forbidden)
            XCTAssertTrue(res.body.string.contains("forbidden.userShouldBeAdmin"))
        }
    }
    
    func testConvertToUserWithInexistantPendingUserFails() async throws {
        let user = try await User.create(username: expectedUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        try app.test(.POST, "\(baseRoute)/2345/convertToUser") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.pendingUser"))
        }
    }
}
