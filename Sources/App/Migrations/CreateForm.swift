//
//  CreateForm.swift
//
//
//  Created by Raphaël Payet on 05/05/2024.
//

import Fluent

struct CreateForm: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Form.v20240207.schemaName)
            .id()
            .field(Form.v20240207.title, .string, .required)
            .field(Form.v20240207.value, .string, .required)
            .field(Form.v20240207.clientID, .string, .required)
            .field(Form.v20240207.createdBy, .string)
            .field(Form.v20240207.createdAt, .date)
            .field(Form.v20240207.updatedBy, .string)
            .field(Form.v20240207.updatedAt, .date)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(Form.v20240207.schemaName)
            .delete()
    }
}

