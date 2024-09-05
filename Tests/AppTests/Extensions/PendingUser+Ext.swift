//
//  PendingUserController+Ext.swift
//  
//
//  Created by Raphaël Payet on 05/09/2024.
//

@testable import App
import XCTVapor
import Fluent

extension PendingUser {
    // TODO: Check if we still need this method
    static func create(
        firstName: String, lastName: String,
        phoneNumber: String, companyName: String,
        email: String, products: String,
        numberOfEmployees: Int?, numberOfUsers: Int?,
        salesAmount: Double?, on database: Database) async throws -> PendingUser {
            let pendingUser = PendingUser(firstName: firstName, lastName: lastName,
                                          phoneNumber: phoneNumber, companyName: companyName,
                                          email: email, products: products,
                                          numberOfEmployees: numberOfEmployees, numberOfUsers: numberOfUsers,
                                          salesAmount: salesAmount)
            try await pendingUser.save(on: database)
            return pendingUser
    }
    
    func addModules(_ modules: [Module], on db: Database) async throws {
        self.modules = modules
        try await self.update(on: db)
    }
    
    static func deleteAll(on database: Database) async throws {
        try await PendingUser.query(on: database)
            .withDeleted()
            .all()
            .delete(force: true, on: database)
    }
}

extension PendingUserControllerTests {
    func createExpectedPendingUser(on db: Database) async throws -> PendingUser {
        let pendingUser = PendingUser(firstName: expectedFirstName,
                                      lastName: expectedLastName,
                                      phoneNumber: expectedPhoneNumber,
                                      companyName: expectedCompanyName,
                                      email: expectedEmail,
                                      products: expectedProducts,
                                      numberOfEmployees: expectedNumberOfEmployees,
                                      numberOfUsers: expectedNumberOfUsers,
                                      salesAmount: expectedSalesAmount)
        
        try await pendingUser.save(on: db)
        return pendingUser
    }
    
    func createExpectedPendingUserInput() -> PendingUser.Input {
        let input = PendingUser.Input(firstName: expectedFirstName, lastName: expectedLastName,
                                                 phoneNumber: expectedPhoneNumber, companyName: expectedCompanyName,
                                                 email: expectedEmail, products: expectedProducts, numberOfEmployees: expectedNumberOfEmployees, numberOfUsers: expectedNumberOfUsers, salesAmount: expectedSalesAmount)
        return input
    }
}
