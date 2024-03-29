//
//  CreateToken.swift
//
//
//  Created by Raphaël Payet on 07/02/2024.
//

import Fluent

struct CreateToken: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Token.v20240207.schemaName)
            .id()
            .field(Token.v20240207.value, .string, .required)
            .field(Token.v20240207.userID, .uuid, .required,
                   .references(User.v20240207.schemaName, User.v20240207.id, onDelete: .cascade))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(Token.v20240207.schemaName)
            .delete()
    }
}
