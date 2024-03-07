//
//  CreateEmployee.swift
//
//
//  Created by Raphaël Payet on 07/03/2024.
//

import Fluent

struct CreateEmployee: AsyncMigration {
    func prepare(on database: Database) async throws {
        
        try await database.schema(Employee.v20240207.schemaName)
            .id()
            .field(Employee.v20240207.firstName, .string, .required)
            .field(Employee.v20240207.lastName, .string, .required)
            .field(Employee.v20240207.username, .string, .required)
            .field(Employee.v20240207.password, .string, .required)
            .field(Employee.v20240207.userID, .uuid, .required,
                   .references(User.v20240207.schemaName, User.v20240207.id, onDelete: .cascade))
            .unique(on: Employee.v20240207.username)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(Employee.v20240207.schemaName)
            .delete()
    }
}
