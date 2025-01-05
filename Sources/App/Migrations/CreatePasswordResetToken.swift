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
        try await database.schema(PasswordResetToken.v20240207.schemaName)
            .id()
            .field(PasswordResetToken.v20240207.token, .string, .required)
            .field(PasswordResetToken.v20240207.userID, .uuid, .required,
                   .references(User.v20240207.schemaName, User.v20240207.id))
            .field(PasswordResetToken.v20240207.userEmail, .string, .required)
            .field(PasswordResetToken.v20240207.expiresAt, .date, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(PasswordResetToken.v20240207.schemaName)
            .delete()
    }
}
