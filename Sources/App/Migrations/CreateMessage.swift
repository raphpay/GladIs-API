//
//  CreateMessage.swift
//
//
//  Created by Raphaël Payet on 29/03/2024.
//

import Fluent

struct CreateMessage: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Message.v20240207.schemaName)
            .id()
            .field(Message.v20240207.content, .string, .required)
            .field(Message.v20240207.title, .string, .required)
            .field(Message.v20240207.senderID, .uuid, .required,
                   .references(User.v20240207.schemaName, User.v20240207.id, onDelete: .cascade))
            .field(Message.v20240207.receiverID, .uuid, .required,
                   .references(User.v20240207.schemaName, User.v20240207.id, onDelete: .cascade))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(Message.v20240207.schemaName)
            .delete()
    }
}
