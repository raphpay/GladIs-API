//
//  CreateModule.swift
//
//
//  Created by Raphaël Payet on 07/02/2024.
//

import Fluent

struct CreateModule: AsyncMigration {    
    func prepare(on database: Database) async throws {
        try await database.schema(Module.v20240207.schemaName)
            .id()
            .field(Module.v20240207.name, .string, .required)
            .unique(on: Module.v20240207.name)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(Module.v20240207.schemaName)
            .delete()
    }
}
