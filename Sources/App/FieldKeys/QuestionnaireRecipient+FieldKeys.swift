//
//  QuestionnaireRecipient+FieldKeys.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 22/01/2025.
//

import Fluent

extension QuestionnaireRecipient {
    enum v20240806 {
        static let schemaName = "questionnaire_recipients"
        
        static let id = FieldKey(stringLiteral: "id")
        static let questionnaireID = FieldKey(stringLiteral: "questionnaire_id")
        static let clientID = FieldKey(stringLiteral: "client_id")
        static let status = FieldKey(stringLiteral: "status")
        static let sentAt = FieldKey(stringLiteral: "sent_at")
        static let viewedAt = FieldKey(stringLiteral: "viewed_at")
        static let submittedAt = FieldKey(stringLiteral: "submitted_at")
        static let createdAt = FieldKey(stringLiteral: "created_at")
    }
}
