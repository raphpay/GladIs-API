//
//  CreateAdminUser.swift
//  
//
//  Created by Raphaël Payet on 07/02/2024.
//

import Fluent
import Vapor

struct CreateAdminUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(AdminUser.v20240207.schemaName)
            .id()
            .field(AdminUser.v20240207.firstName, .string, .required)
            .field(AdminUser.v20240207.lastName, .string, .required)
            .field(AdminUser.v20240207.phoneNumber, .string, .required)
            .field(AdminUser.v20240207.email, .string, .required)
            .field(AdminUser.v20240207.firstConnection, .bool, .required)
            .field(AdminUser.v20240207.username, .string, .required)
            .field(AdminUser.v20240207.password, .string, .required)
            .unique(on: AdminUser.v20240207.username)
            .unique(on: AdminUser.v20240207.email)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(AdminUser.v20240207.schemaName)
            .delete()
    }
}
