//
//  PotentialEmployeeControllerTests+CREATE.swift
//
//
//  Created by Raphaël Payet on 17/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Create
extension PotentialEmployeeControllerTests {
    func testCreatePotentialEmployeeSucceed() async throws {
        let pendingUser = try await PendingUser.create(firstName: expectedPendingUserFirstName, lastName: expectedPendingUserLastName,
                                                       phoneNumber: expectedPendingUserPhoneNumber, companyName: expectedPendingUserCompanyName,
                                                       email: expectedPendingUserEmail, products: expectedPendingUserProducts,
                                                       numberOfEmployees: expectedPendingUserNumberOfEmployees, numberOfUsers: expectedPendingUserNumberOfUsers,
                                                       salesAmount: expectedPendingUserSalesAmount, on: app.db)
        let pendingUserID = try pendingUser.requireID()
        let employeeInput = PotentialEmployee.Input(firstName: expectedFirstName, lastName: expectedLastName, companyName: expectedCompanyName, phoneNumber: expectedPhoneNumber, email: expectedEmail, pendingUserID: pendingUserID)
        
        try app.test(.POST, baseRoute) { req in
            try req.content.encode(employeeInput)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let createdEmployee = try res.content.decode(PotentialEmployee.self)
            XCTAssertEqual(createdEmployee.firstName, expectedFirstName)
            XCTAssertEqual(createdEmployee.lastName, expectedLastName)
            XCTAssertEqual(createdEmployee.$pendingUser.id, pendingUserID)
        }
    }
}

// MARK: - Convert To User
extension PotentialEmployeeControllerTests {
    func testConvertToUserSuceed() async throws {
        let pendingUser = try await PendingUser.create(firstName: expectedPendingUserFirstName, lastName: expectedPendingUserLastName,
                                                       phoneNumber: expectedPendingUserPhoneNumber, companyName: expectedPendingUserCompanyName,
                                                       email: expectedPendingUserEmail, products: expectedPendingUserProducts,
                                                       numberOfEmployees: expectedPendingUserNumberOfEmployees, numberOfUsers: expectedPendingUserNumberOfUsers,
                                                       salesAmount: expectedPendingUserSalesAmount, on: app.db)
        let pendingUserID = try pendingUser.requireID()
        let employee = try await PotentialEmployee.create(firstName: expectedFirstName, lastName: expectedLastName, companyName: expectedCompanyName, phoneNumber: expectedPhoneNumber, email: expectedEmail, pendingUserID: pendingUserID, on: app.db)
        let employeeID = try employee.requireID()
        
        let user = try await User.create(username: expectedAdminUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        let path = "\(baseRoute)/\(employeeID)/convertToUser"
        try app.test(.POST, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let createdUser = try res.content.decode(User.Public.self)
            XCTAssertEqual(createdUser.firstName, employee.firstName)
            XCTAssertEqual(createdUser.lastName, employee.lastName)
        }
    }
    
    func testConvertToUserWithInexistantEmployeeFails() async throws {
        let user = try await User.create(username: expectedAdminUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        let path = "\(baseRoute)/12345/convertToUser"
        try app.test(.POST, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.employee"))
        }
    }
}
