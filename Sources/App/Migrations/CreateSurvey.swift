//
//  CreateSurvey.swift
//
//
//  Created by Raphaël Payet on 23/04/2024.
//

import Fluent

struct CreateSurvey: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Survey.v20240207.schemaName)
            .id()
            .field(Survey.v20240207.value, .string, .required)
            .field(Survey.v20240207.createdAt, .date)
            .field(Survey.v20240207.updatedAt, .date)
            .field(Survey.v20240207.clientID, .uuid, .required,
                   .references(User.v20240207.schemaName, User.v20240207.id, onDelete: .cascade))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(Survey.v20240207.schemaName)
            .delete()
    }
}

