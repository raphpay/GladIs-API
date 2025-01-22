//
//  QuestionnaireDTO.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 22/01/2025.
//

import Fluent
import Vapor

extension Questionnaire {
    struct Input: Content {
        let title: String
        let fields: [QField]
        let adminID: User.IDValue
        let sentAt: Date?
        let sentCount: Int
        let responseCount: Int
        
        func toModel() -> Questionnaire {
            .init(title: title,
                  fields: fields,
                  adminID: adminID,
                  sentCount: sentCount,
                  responseCount: responseCount,
                  sentAt: sentAt
            )
        }
    }
}
