//
//  CreateQuestionnaireRecipient.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 22/01/2025.
//

import Fluent

struct CreateQuestionnaireRecipient: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(QuestionnaireRecipient.v20240806.schemaName)
            .id()
            .field(QuestionnaireRecipient.v20240806.questionnaireID,
                   .uuid,
                   .required,
                   .references(Questionnaire.v20240806.schemaName, Questionnaire.v20240806.id,
                               onDelete: .cascade)
            )
            .field(QuestionnaireRecipient.v20240806.clientID,
                   .uuid,
                   .required,
                   .references(User.v20240207.schemaName, User.v20240207.id,
                               onDelete: .cascade)
            )
            .field(QuestionnaireRecipient.v20240806.createdAt, .date, .required)
            .field(QuestionnaireRecipient.v20240806.status, .string, .required)
            .field(QuestionnaireRecipient.v20240806.sentAt, .date, .required)
            .field(QuestionnaireRecipient.v20240806.viewedAt, .date)
            .field(QuestionnaireRecipient.v20240806.submittedAt, .date)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(QuestionnaireRecipient.v20240806.schemaName)
            .delete()
    }
}

