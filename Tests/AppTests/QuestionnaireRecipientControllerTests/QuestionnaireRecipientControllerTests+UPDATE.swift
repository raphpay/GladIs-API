//
//  QuestionnaireRecipientControllerTests+UPDATE.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 23/01/2025.
//

@testable import App
import XCTVapor
import Fluent

// MARK: - Mark as viewed
extension QuestionnaireRecipientControllerTests {
    func test_MarkAsViewed_Succeed() async throws {
        // Given
        let qRecipient = try await QuestionnaireRecipientControllerTests().createExpectedQRecipient(
            qID: qID,
            clientID: clientID,
            on: app.db
        )
        
        let expectedRecipientID = try qRecipient.requireID()
        
        try await app.test(.PUT, "\(baseURL)/viewed/\(expectedRecipientID)", beforeRequest: { req in
            // Add the Bearer token for authentication
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .ok)
            do {
                let questionnaireRecipient = try res.content.decode(QuestionnaireRecipient.self)
                XCTAssertEqual(questionnaireRecipient.status, .viewed)
            } catch {}
        })
    }
    
    func test_MarkAsViewed_WithInexistantQRecipient_Fails() async throws {
        let id = UUID()
        
        try await app.test(.PUT, "\(baseURL)/viewed/\(id)", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.qRecipient"))
        })
    }
}
