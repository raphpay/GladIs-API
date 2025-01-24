//
//  QuestionnaireRecipientControllerTests+DELETE.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 23/01/2025.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Remove All
extension QuestionnaireRecipientControllerTests {
    func test_RemoveAll_Succeed() async throws {
        let _ = try await QuestionnaireRecipientControllerTests().createExpectedQRecipient(qID: qID,
                                                                                                    clientID: clientID,
                                                                                                    on: app.db)
        
        try await app.test(.DELETE, "\(baseURL)/all", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .noContent)
            do {
                let questionnaireRecipients = try await QuestionnaireRecipient.query(on: app.db).all()
                XCTAssertEqual(questionnaireRecipients.count, 0)
            } catch {}
        })
    }
    
    func test_RemoveAll_WithUnauthorizedRole_Fails() async throws {
        let _ = try await QuestionnaireRecipientControllerTests().createExpectedQRecipient(qID: qID,
                                                                                                    clientID: clientID,
                                                                                                    on: app.db)
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
