//
//  QuestionnaireRecipientDTO.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 22/01/2025.
//

import Fluent
import Vapor

// MARK: Create
extension QuestionnaireRecipient {
    struct Input: Content {
        let questionnaireID: Questionnaire.IDValue
        let clientID: User.IDValue
        let status: Status
        let sentAt: Date

        func toModel() -> QuestionnaireRecipient {
            .init(questionnaireID: questionnaireID,
                  clientID: clientID,
                  status: status,
                  sentAt: sentAt
            )
        }
    }
}

// MARK: Update
extension QuestionnaireRecipient {
    struct UpdateInput: Content {
        let fields: [QRField]
    }

    struct UpdateStatusInput: Content {
        let status: Status
    }
}
