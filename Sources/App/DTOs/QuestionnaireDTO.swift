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
        let responseCount: Int
        let clientIDs: [User.IDValue]
        
        func toModel() -> Questionnaire {
            .init(title: title,
                  fields: fields,
                  adminID: adminID,
                  sentCount: clientIDs.count,
                  responseCount: responseCount,
                  sentAt: sentAt
            )
        }
    }
}
