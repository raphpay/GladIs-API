//
//  CreateModulePendingUserPivot.swift
//
//
//  Created by Raphaël Payet on 12/02/2024.
//

import Fluent

struct CreateModulePendingUserPivot: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(ModulePendingUserPivot.v20240207.schemaName)
            .id()
            .field(ModuleUserPivot.v20240207.moduleID, .uuid, .required,
                   .references(Module.v20240207.schemaName, Module.v20240207.id))
            .field(ModuleUserPivot.v20240207.userID, .uuid, .required,
                .references(PendingUser.v20240207.schemaName, PendingUser.v20240207.id))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(ModulePendingUserPivot.v20240207.schemaName)
            .delete()
    }
}
