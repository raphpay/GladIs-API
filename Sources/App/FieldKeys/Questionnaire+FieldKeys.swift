//
//  Questionnaire+FieldKeys.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 22/01/2025.
//

import Fluent

extension Questionnaire {
    enum v20240806 {
        static let schemaName = "questionnaires"
        static let id = FieldKey(stringLiteral: "id")
        static let title = FieldKey(stringLiteral: "title")
        static let fields = FieldKey(stringLiteral: "fields")
        static let adminID = FieldKey(stringLiteral: "admin_id")
        static let createdAt = FieldKey(stringLiteral: "created_at")
        static let sentAt = FieldKey(stringLiteral: "sent_at")
        static let updatedAt = FieldKey(stringLiteral: "updated_at")
        static let sentCount = FieldKey(stringLiteral: "sent_count")
        static let responseCount = FieldKey(stringLiteral: "response_count")
        static let questionnaireRecipients = FieldKey(stringLiteral: "questionnaire_recipients")
    }
}
