//
//  PotentialEmployeeControllerTests+READ.swift
//
//
//  Created by Raphaël Payet on 17/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Get All
extension PotentialEmployeeControllerTests {
    func testGetAllPotentialEmployeeSuceed() async throws {
        try await PotentialEmployee.deleteAll(on: app.db)
        let pendingUser = try await PendingUser.create(firstName: expectedPendingUserFirstName, lastName: expectedPendingUserLastName,
                                                       phoneNumber: expectedPendingUserPhoneNumber, companyName: expectedPendingUserCompanyName,
                                                       email: expectedPendingUserEmail, products: expectedPendingUserProducts,
                                                       numberOfEmployees: expectedPendingUserNumberOfEmployees, numberOfUsers: expectedPendingUserNumberOfUsers,
                                                       salesAmount: expectedPendingUserSalesAmount, on: app.db)
        let pendingUserID = try pendingUser.requireID()
        let employee = try await PotentialEmployee.create(firstName: expectedFirstName, lastName: expectedLastName, companyName: expectedCompanyName, phoneNumber: expectedPhoneNumber, email: expectedEmail, pendingUserID: pendingUserID, on: app.db)
        
        let user = try await User.create(username: expectedAdminUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        try app.test(.GET, baseRoute) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let employees = try res.content.decode([PotentialEmployee].self)
            XCTAssertEqual(employees.count, 1)
        }
    }
    
    func testGetEmptyEmployeeSucceedWithEmptyResponse() async throws {
        try await PotentialEmployee.deleteAll(on: app.db)
        let user = try await User.create(username: expectedAdminUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        
        try app.test(.GET, baseRoute) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let employees = try res.content.decode([PotentialEmployee].self)
            XCTAssertEqual(employees.count, 0)
        }
    }
}
