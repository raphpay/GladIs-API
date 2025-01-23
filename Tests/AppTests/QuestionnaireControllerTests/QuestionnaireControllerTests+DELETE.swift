//
//  QuestionnaireControllerTests+DELETE.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 23/01/2025.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Remove all
extension QuestionnaireControllerTests {
    func test_RemoveAll_Succeed() async throws {
        let adminID = try admin.requireID()
        let _ = try await QuestionnaireControllerTests().createExpectedQuestionnaire(adminID: adminID, on: app.db)
        try await app.test(.DELETE, "\(baseURL)/all", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .noContent)
            do {
                let questionnaires = try await Questionnaire.query(on: app.db).all()
                XCTAssertEqual(questionnaires.count, 0)
            } catch {}
        })
    }
    
    func test_RemoveAll_WithoutAuthorizedRole_Fails() async throws {
        let adminID = try admin.requireID()
        let _ = try await QuestionnaireControllerTests().createExpectedQuestionnaire(adminID: adminID, on: app.db)
        
        let unauthorizedUser = try await UserControllerTests().createExpectedUser(userType: .client, on: app.db)
        let unauthorizedToken = try await Token.create(for: unauthorizedUser, on: app.db)
        
        try await app.test(.DELETE, "\(baseURL)/all", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: unauthorizedToken.value)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.role"))
        })
    }
}
