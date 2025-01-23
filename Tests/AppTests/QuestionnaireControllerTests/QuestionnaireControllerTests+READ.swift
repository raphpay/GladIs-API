//
//  QuestionnaireControllerTests+READ.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 23/01/2025.
//

@testable import App
import XCTVapor
import Fluent
import Vapor

// MARK: - Get All
extension QuestionnaireControllerTests {
    func test_GetAll_Succeed() async throws {
        let adminID = try admin.requireID()
        let _ = try await QuestionnaireControllerTests().createExpectedQuestionnaire(adminID: adminID, on: app.db)
        
        try await app.test(.GET, baseURL, beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .ok)
            do {
                let questionnaires = try res.content.decode([Questionnaire].self)
                XCTAssertEqual(questionnaires.count, 1)
                XCTAssertEqual(questionnaires[0].title, expectedTitle)
                XCTAssertEqual(questionnaires[0].fields.count, expectedFields.count)
            } catch { }
        })
    }
}
