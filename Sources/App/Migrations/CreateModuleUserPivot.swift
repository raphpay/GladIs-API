//
//  CreateModuleUserPivot.swift
//
//
//  Created by Raphaël Payet on 07/02/2024.
//

import Fluent

struct CreateModuleUserPivot: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database
            .schema(ModuleUserPivot.v20240207.schemaName)
            .id()
            .field(ModuleUserPivot.v20240207.moduleID, .uuid, .required,
                   .references(Module.v20240207.schemaName, Module.v20240207.id))
            .field(ModuleUserPivot.v20240207.userID, .uuid, .required,
                .references(User.v20240207.schemaName, User.v20240207.id))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(ModuleUserPivot.v20240207.schemaName)
            .delete()
    }
}
