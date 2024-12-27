//
//  File.swift
//  
//
//  Created by Raphaël Payet on 22/02/2024.
//

import Fluent

struct CreateDocument: AsyncMigration {
    func prepare(on database: Database) async throws {
        
        try await database.schema(Document.v20240207.schemaName)
            .id()
            .field(Document.v20240207.name, .string, .required)
            .field(Document.v20240207.path, .string, .required)
            .field(Document.v20240207.lastModified, .date)
            .field(Document.v20240207.status, .string, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(Document.v20240207.schemaName)
            .delete()
    }
}
