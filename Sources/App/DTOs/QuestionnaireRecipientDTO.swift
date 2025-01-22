//
//  QuestionnaireRecipientDTO.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 22/01/2025.
//

import Fluent
import Vapor

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
