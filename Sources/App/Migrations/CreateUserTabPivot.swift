//
//  CreateUserTabPivot.swift
//
//
//  Created by Raphaël Payet on 29/02/2024.
//

import Fluent

struct CreateUserTabPivot: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(UserTabPivot.v20240207.schemaName)
            .id()
            .field(UserTabPivot.v20240207.userID, .uuid, .required,
                   .references(User.v20240207.schemaName, User.v20240207.id))
            .field(UserTabPivot.v20240207.tabID, .uuid, .required,
                .references(TechnicalDocumentationTab.v20240207.schemaName, TechnicalDocumentationTab.v20240207.id))
            .unique(on: TechnicalDocumentationTab.v20240207.id)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(UserTabPivot.v20240207.schemaName)
            .delete()
    }
}
