//
//  CreateDocumentActivityLog.swift
//
//
//  Created by Raphaël Payet on 29/02/2024.
//

import Fluent

struct CreateDocumentActivityLog: AsyncMigration {
    func prepare(on database: Database) async throws {
        
        let action = try await database.enum(DocumentActivityLog.v20240207.action)
            .case(DocumentActivityLog.v20240207.creation)
            .case(DocumentActivityLog.v20240207.modification)
            .case(DocumentActivityLog.v20240207.approbation)
            .case(DocumentActivityLog.v20240207.visualisation)
            .case(DocumentActivityLog.v20240207.loaded)
            .case(DocumentActivityLog.v20240207.deletion)
            .case(DocumentActivityLog.v20240207.signature)
            .create()
        
        try await database.schema(DocumentActivityLog.v20240207.schemaName)
            .id()
            .field(DocumentActivityLog.v20240207.name, .string, .required)
            .field(DocumentActivityLog.v20240207.actorUsername, .string, .required)
            .field(DocumentActivityLog.v20240207.actionDate, .date, .required)
            .field(DocumentActivityLog.v20240207.actorIsAdmin, .bool, .required)
            .field(DocumentActivityLog.v20240207.actionEnum, action, .required)
            .field(DocumentActivityLog.v20240207.documentID, .uuid, .required,
                   .references(Document.v20240207.schemaName, Document.v20240207.id, onDelete: .cascade))
            .field(DocumentActivityLog.v20240207.clientID, .uuid, .required,
                   .references(User.v20240207.schemaName, User.v20240207.id, onDelete: .cascade))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(DocumentActivityLog.v20240207.schemaName)
            .delete()
    }
}
