//
//  PotentialEmployee+Ext.swift
//  
//
//  Created by Raphaël Payet on 05/09/2024.
//

@testable import App
import XCTVapor
import Fluent

extension PotentialEmployee {
    static func create(
        firstName: String, lastName: String,
        companyName: String, phoneNumber: String,
        email: String, pendingUserID: PendingUser.IDValue,
        on database: Database) async throws -> PotentialEmployee {
            let employee = PotentialEmployee(firstName: firstName, lastName: lastName, companyName: companyName, phoneNumber: phoneNumber, email: email, pendingUserID: pendingUserID)
            try await employee.save(on: database)
            return employee
        }
    
    static func deleteAll(on database: Database) async throws {
        try await PotentialEmployee.query(on: database)
            .withDeleted()
            .all()
            .delete(force: true, on: database)
    }
}
