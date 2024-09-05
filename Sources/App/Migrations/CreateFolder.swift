//
//  CreateFolder.swift
//  
//
//  Created by Raphaël Payet on 06/08/2024.
//

import Fluent
import Vapor

struct CreateFolder: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Folder.v20240806.schemaName)
            .id()
            .field(Folder.v20240806.title, .string, .required)
            .field(Folder.v20240806.number, .int, .required)
            .field(Folder.v20240806.sleeve, .string, .required)
            .field(Folder.v20240806.userID, .uuid, .required,
                   .references(User.v20240207.schemaName, User.v20240207.id, onDelete: .cascade))
            .field(Folder.v20240806.path, .string)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(User.v20240207.schemaName)
            .deleteField(User.v20240806.systemQualityFolders)
            .deleteField(User.v20240806.recordsFolders)
            .update()
        
        try await database
            .schema(Folder.v20240806.schemaName)
            .delete()
    }
}
