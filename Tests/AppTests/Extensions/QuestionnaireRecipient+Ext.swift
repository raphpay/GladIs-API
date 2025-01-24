//
//  QuestionnaireRecipient+Ext.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 23/01/2025.
//

@testable import App
import XCTVapor
import Fluent

extension QuestionnaireRecipientControllerTests {
    func createExpectedQRecipient(qID: Questionnaire.IDValue,
                                  clientID: User.IDValue,
                                  status: QuestionnaireRecipient.Status = .sent,
                                  on db: Database) async throws -> QuestionnaireRecipient {
        let qRecipient = QuestionnaireRecipient(questionnaireID: qID,
                                                clientID: clientID,
                                                status: status,
                                                sentAt: Date())
        try await qRecipient.save(on: db)
        
        return qRecipient
    }
}
