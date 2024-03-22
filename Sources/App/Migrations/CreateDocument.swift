//
//  File.swift
//  
//
//  Created by Raphaël Payet on 22/02/2024.
//

import Fluent

struct CreateDocument: AsyncMigration {
    func prepare(on database: Database) async throws {
        
        let status = try await database.enum(Document.v20240207.status)
            .case(Document.v20240207.draft)
            .case(Document.v20240207.pendingReview)
            .case(Document.v20240207.underReview)
            .case(Document.v20240207.approved)
            .case(Document.v20240207.rejected)
            .case(Document.v20240207.archived)
            .case(Document.v20240207.none)
            .create()
        
        try await database.schema(Document.v20240207.schemaName)
            .id()
            .field(Document.v20240207.name, .string, .required)
            .field(Document.v20240207.path, .string, .required)
            .field(Document.v20240207.statusEnum, status, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(Document.v20240207.schemaName)
            .delete()
    }
}
