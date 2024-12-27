//
//  AddCategoryToFolder.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 27/12/2024.
//

import Fluent
import Vapor

struct AddCategoryToFolder: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Folder.v20240806.schemaName)
            .field(Folder.v20241227.category, .string, .required)
            .update()
        
        // Set default values
        try await Folder.query(on: database)
            .set(\.$category, to: .custom)
            .update()
    }

    func revert(on database: Database) async throws {
        // Revert the changes by removing the 'category' field.
        try await database.schema(Folder.v20240806.schemaName)
            .deleteField(Folder.v20241227.category)
            .update()
    }
}
