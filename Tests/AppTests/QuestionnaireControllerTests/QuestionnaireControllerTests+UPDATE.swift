//
//  QuestionnaireControllerTests+UPDATE.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 23/01/2025.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Update
extension QuestionnaireControllerTests {
    func test_Update_Succeed() async throws {
        let adminID = try admin.requireID()
        let questionnaire = try await QuestionnaireControllerTests().createExpectedQuestionnaire(adminID: adminID, on: app.db)
        let qID = try questionnaire.requireID()
        
        let newTitle = "newTitle"
        let newFields = [Questionnaire.QField(key: "new key 1", index: 1)]
        
        let updateInput = Questionnaire.UpdateInput(title: newTitle,
                                                    fields: newFields)
        
        try await app.test(.PUT, "\(baseURL)/\(qID)", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(updateInput)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .ok)
            do {
                let updatedQuestionnaire = try res.content.decode(Questionnaire.self)
                XCTAssertEqual(updatedQuestionnaire.title, newTitle)
            } catch {}
        })
    }
    
    func test_Update_WithInexistantQuestionnaire_Fails() async throws {
        let newTitle = "newTitle"
        let newFields = [Questionnaire.QField(key: "new key 1", index: 1)]
        
        let updateInput = Questionnaire.UpdateInput(title: newTitle,
                                                    fields: newFields)
        
        try await app.test(.PUT, "\(baseURL)/\(UUID())", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(updateInput)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.questionnaire"))
        })
    }
}
