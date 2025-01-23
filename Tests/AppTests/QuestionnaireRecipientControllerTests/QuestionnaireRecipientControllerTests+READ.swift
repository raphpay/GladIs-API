//
//  QuestionnaireRecipientControllerTests+READ.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 23/01/2025.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Get All
extension QuestionnaireRecipientControllerTests {
    func test_GetAll_Succeed() async throws {
        let _ = try await QuestionnaireRecipientControllerTests().createExpectedQRecipient(qID: qID,
                                                                                                    clientID: clientID,
                                                                                                    on: app.db)
        
        try await app.test(.GET, "\(baseURL)/all", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .ok)
            do {
                let qRecipient = try res.content.decode(QuestionnaireRecipient.self)
                XCTAssertEqual(qRecipient.$questionnaire.id, qID)
                XCTAssertEqual(qRecipient.$client.id, clientID)
                XCTAssertEqual(qRecipient.status, .sent)
            } catch {}
        })
    }
    
    func test_GetAll_WithUnauthorizedUser_Fails() async throws {
        let _ = try await QuestionnaireRecipientControllerTests().createExpectedQRecipient(qID: qID,
                                                                                                    clientID: clientID,
                                                                                                    on: app.db)
        let unauthorizedUser = try await UserControllerTests().createExpectedUser(userType: .client, on: app.db)
        let unauthorizedToken = try await Token.create(for: unauthorizedUser, on: app.db)
        
        try await app.test(.GET, "\(baseURL)/all", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: unauthorizedToken.value)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.role"))
        })
    }
}
