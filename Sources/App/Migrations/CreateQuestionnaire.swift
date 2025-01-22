//
//  CreateQuestionnaire.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 22/01/2025.
//

import Fluent

struct CreateQuestionnaire: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Questionnaire.v20240806.schemaName)
            .id()
            .field(Questionnaire.v20240806.title, .string, .required)
            .field(Questionnaire.v20240806.fields, .array(of: .custom(Questionnaire.QField.self)), .required)
            .field(Questionnaire.v20240806.adminID, .uuid, .required)
            .field(Questionnaire.v20240806.createdAt, .date)
            .field(Questionnaire.v20240806.sentAt, .date)
            .field(Questionnaire.v20240806.sentCount, .int, .required)
            .field(Questionnaire.v20240806.responseCount, .int, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(Questionnaire.v20240806.schemaName)
            .delete()
    }
}

