//
//  CreatePotentialEmployee.swift
//
//
//  Created by Raphaël Payet on 06/03/2024.
//

import Fluent

struct CreatePotentialEmployee: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database
            .schema(PotentialEmployee.v20240207.schemaName)
            .id()
            .field(PotentialEmployee.v20240207.firstName, .string, .required)
            .field(PotentialEmployee.v20240207.lastName, .string, .required)
            .field(PotentialEmployee.v20240207.companyName, .string, .required)
            .field(PotentialEmployee.v20240207.phoneNumber, .string, .required)
            .field(PotentialEmployee.v20240207.email, .string, .required)
            .field(PotentialEmployee.v20240207.pendingUserID, .uuid, .required)
            .unique(on: PotentialEmployee.v20240207.email)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(PotentialEmployee.v20240207.schemaName)
            .delete()
    }
}
