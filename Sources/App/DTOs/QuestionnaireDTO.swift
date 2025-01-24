//
//  QuestionnaireDTO.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 22/01/2025.
//

import Fluent
import Vapor

// MARK: - Create
extension Questionnaire {
    struct Input: Content {
        let title: String
        let fields: [QField]
        let adminID: User.IDValue
        let clientIDs: [User.IDValue]
        
        func toModel() -> Questionnaire {
            .init(title: title,
                  fields: fields,
                  adminID: adminID,
                  sentCount: clientIDs.count,
                  responseCount: 0,
                  sentAt: Date()
            )
        }
    }
}

// MARK: - Update
extension Questionnaire {
    struct UpdateInput: Content {
        let title: String?
        let fields: [QField]?
        
        func update(questionnaire: Questionnaire) -> Questionnaire {
            let updatedQuestionnaire = questionnaire
            
            if let title = title {
                updatedQuestionnaire.title = title
            }
            
            if let fields = fields {
                updatedQuestionnaire.fields = fields
            }
            
            return updatedQuestionnaire
        }
    }
}
