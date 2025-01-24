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

// MARK: - Get Questionnaire
extension QuestionnaireRecipientControllerTests {
    func test_GetQuestionnaire_Succeed() async throws {
        // Given
        let qRecipient = try await QuestionnaireRecipientControllerTests().createExpectedQRecipient(
            qID: qID,
            clientID: clientID,
            on: app.db
        )
        
        let expectedRecipientID = try qRecipient.requireID()
        
        try await app.test(.GET, "\(baseURL)/questionnaire/\(expectedRecipientID)", beforeRequest: { req in
            // Add the Bearer token for authentication
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .ok)
            
            // Decode the response as a `Questionnaire`
            do {
                let questionnaire = try res.content.decode(Questionnaire.self)
                
                // Check if the questionnaire matches the expected data
                XCTAssertEqual(questionnaire.id, qID)
                
                // Verify the recipient's status has been updated in the database
                guard let updatedRecipient = try await QuestionnaireRecipient.find(expectedRecipientID, on: app.db) else {
                    XCTFail("QuestionnaireRecipient not found in the database")
                    return
                }
                XCTAssertEqual(updatedRecipient.status, .viewed)
            } catch {
                XCTFail("Failed to decode response or validate data: \(error.localizedDescription)")
            }
        })
    }
    
    func test_GetQuestionnaire_WithInexistantRecipient_Fails() async throws {
        let expectedRecipientID = UUID()
        
        try await app.test(.GET, "\(baseURL)/questionnaire/\(expectedRecipientID)", beforeRequest: { req in
            // Add the Bearer token for authentication
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res async in
            // Then
            print("res.body.string \(res.body.string)")
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.qRecipient"))
        })
    }
    
    func test_GetQuestionnaire_WithInexistantQuestionnaire_Fails() async throws {
        // Given
        let qRecipient = try await QuestionnaireRecipientControllerTests().createExpectedQRecipient(
            qID: UUID(),
            clientID: clientID,
            on: app.db
        )
        
        let expectedRecipientID = try qRecipient.requireID()
        
        try await app.test(.GET, "\(baseURL)/questionnaire/\(expectedRecipientID)", beforeRequest: { req in
            // Add the Bearer token for authentication
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.questionnaire"))
        })
    }
}

// MARK: - Get All For client
extension QuestionnaireRecipientControllerTests {
    func test_GetAllForClient_Succeed() async throws {
        let _ = try await QuestionnaireRecipientControllerTests().createExpectedQRecipient(qID: qID, clientID: clientID, on: app.db)
        let castedClientID = clientID as User.IDValue
        
        try await app.test(.GET, "\(baseURL)/all/for/client/\(castedClientID)", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .ok)
            do {
                let qRecipients = try res.content.decode([QuestionnaireRecipient].self)
                XCTAssertEqual(qRecipients.count, 1)
                XCTAssertEqual(qRecipients[0].$questionnaire.id, qID)
                XCTAssertEqual(qRecipients[0].$client.id, clientID)
            } catch {}
        })
    }
}
