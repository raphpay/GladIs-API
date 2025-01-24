//
//  Questionnaire+Ext.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 23/01/2025.
//

@testable import App
import XCTVapor
import Fluent

extension QuestionnaireControllerTests {
    func createExpectedQuestionnaire(adminID: User.IDValue, on db: Database) async throws -> Questionnaire {
        let questionnaire = Questionnaire(title: expectedTitle,
                                          fields: expectedFields,
                                          adminID: adminID)
        
        try await questionnaire.save(on: db)
        
        return questionnaire
    }
}
