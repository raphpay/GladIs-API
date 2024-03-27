//
//  CreatePasswordResetToken.swift
//  
//
//  Created by Raphaël Payet on 26/03/2024.
//

import Fluent
import Vapor

struct CreatePasswordResetToken: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Event.v20240207.schemaName)
            .id()
            .field(Event.v20240207.name, .string, .required)
            .field(Event.v20240207.date, .date, .required)
            .field(Event.v20240207.clientID, .uuid, .required,
                   .references(User.v20240207.schemaName, User.v20240207.id, onDelete: .cascade))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(Event.v20240207.schemaName)
            .delete()
    }
}
