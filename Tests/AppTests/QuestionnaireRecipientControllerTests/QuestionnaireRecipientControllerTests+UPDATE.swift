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

// MARK: - Submit Answer
extension QuestionnaireRecipientControllerTests {
    func test_SubmitAnswer_Succeed() async throws {
        let qRecipient = try await QuestionnaireRecipientControllerTests().createExpectedQRecipient(
            qID: qID,
            clientID: clientID,
            on: app.db
        )
        
        let expectedRecipientID = try qRecipient.requireID()
        
        let newFields = [QuestionnaireRecipient.QRField(key: "Test Field 1", value: "Test Value 1", index: 1), QuestionnaireRecipient.QRField(key: "Test Field 2", value: "Test Value 2", index: 2)]
        
        let updateInput = QuestionnaireRecipient.UpdateInput(fields: newFields)
        try await app.test(.PUT, "\(baseURL)/submit/\(expectedRecipientID)", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(updateInput)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .ok)
            do {
                let questionnaireRecipient = try res.content.decode(QuestionnaireRecipient.self)
                XCTAssertEqual(questionnaireRecipient.fields?.count, newFields.count)
                XCTAssertEqual(questionnaireRecipient.status, .submitted)
                
                let questionnaire = try await Questionnaire.query(on: app.db).first()
                XCTAssertEqual(questionnaire?.responseCount, 1)
            } catch {}
        })
    }
    
    func test_SubmitAnswer_WithInexistantQuestionnaire_Fails() async throws {
        let qRecipient = try await QuestionnaireRecipientControllerTests().createExpectedQRecipient(
            qID: UUID(),
            clientID: clientID,
            on: app.db
        )
        
        let expectedRecipientID = try qRecipient.requireID()
        
        let newFields = [QuestionnaireRecipient.QRField(key: "Test Field 1", value: "Test Value 1", index: 1), QuestionnaireRecipient.QRField(key: "Test Field 2", value: "Test Value 2", index: 2)]
        
        let updateInput = QuestionnaireRecipient.UpdateInput(fields: newFields)
        try await app.test(.PUT, "\(baseURL)/submit/\(expectedRecipientID)", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(updateInput)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.questionnaire"))
        })
    }
    
    func test_SubmitAnswer_WithWrongFields_Fails() async throws {
        let qRecipient = try await QuestionnaireRecipientControllerTests().createExpectedQRecipient(
            qID: qID,
            clientID: clientID,
            on: app.db
        )
        
        let expectedRecipientID = try qRecipient.requireID()
        
        let newFields = [QuestionnaireRecipient.QRField(key: "Test Field 1", value: "Test Value 1", index: 1)]
        
        let updateInput = QuestionnaireRecipient.UpdateInput(fields: newFields)
        try await app.test(.PUT, "\(baseURL)/submit/\(expectedRecipientID)", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(updateInput)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingFields"))
        })
    }
    
    func test_SubmitAnswer_WithIncorrectFields_Fails() async throws {
        let qRecipient = try await QuestionnaireRecipientControllerTests().createExpectedQRecipient(
            qID: qID,
            clientID: clientID,
            on: app.db
        )
        
        let expectedRecipientID = try qRecipient.requireID()
        
        let newFields = [QuestionnaireRecipient.QRField(key: "Test Field 10", value: "Test Value 1", index: 1), QuestionnaireRecipient.QRField(key: "Test Field 2", value: "Test Value 2", index: 2)]
        
        let updateInput = QuestionnaireRecipient.UpdateInput(fields: newFields)
        try await app.test(.PUT, "\(baseURL)/submit/\(expectedRecipientID)", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(updateInput)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.incorrectFields"))
        })
    }
}

