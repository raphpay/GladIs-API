//
//  PotentialEmployeeControllerTests+DELETE.swift
//
//
//  Created by Raphaël Payet on 17/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Remove by Company
extension PotentialEmployeeControllerTests {
    func testRemoveByCompanySucceed() async throws {
        try await PotentialEmployee.deleteAll(on: app.db)
        let pendingUser = try await PendingUser.create(firstName: expectedPendingUserFirstName, lastName: expectedPendingUserLastName,
                                                       phoneNumber: expectedPendingUserPhoneNumber, companyName: expectedPendingUserCompanyName,
                                                       email: expectedPendingUserEmail, products: expectedPendingUserProducts,
                                                       numberOfEmployees: expectedPendingUserNumberOfEmployees, numberOfUsers: expectedPendingUserNumberOfUsers,
                                                       salesAmount: expectedPendingUserSalesAmount, on: app.db)
        let pendingUserID = try pendingUser.requireID()
        let _ = try await PotentialEmployee.create(firstName: expectedFirstName, lastName: expectedLastName, companyName: expectedCompanyName, phoneNumber: expectedPhoneNumber, email: expectedEmail, pendingUserID: pendingUserID, on: app.db)
        
        let user = try await User.create(username: expectedAdminUsername, on: app.db)
        let token = try await Token.create(for: user, on: app.db)
        let companyName = expectedCompanyName
        
        let path = "\(baseRoute)/\(companyName)"
        try await app.test(.DELETE, path, beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
            let employees = try await PotentialEmployee.query(on: app.db).all()
            XCTAssertEqual(employees.count, 0)
        })
    }
}
