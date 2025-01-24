//
//  QuestionnaireControllerTests+CREATE.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 23/01/2025.
//

@testable import App
import XCTVapor
import Fluent
import Vapor

// MARK: - Create
extension QuestionnaireControllerTests {
    func test_Create_Succeed() async throws {
        let client = try await UserControllerTests().createExpectedUser(userType: .client, on: app.db)
        let clientID = try client.requireID()
        let adminID = try admin.requireID()
        let input = Questionnaire.Input(title: expectedTitle,
                                        fields: expectedFields,
                                        adminID: adminID,
                                        clientIDs: [clientID]
        )
        try await app.test(.POST, baseURL, beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(input)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .ok)
            do {
                let questionnaire = try res.content.decode(Questionnaire.self)
                XCTAssertEqual(questionnaire.title, expectedTitle)
                XCTAssertEqual(questionnaire.fields.count, expectedFields.count)
                
                let qID = try questionnaire.requireID()
                let qRecipients = try await QuestionnaireRecipient.query(on: app.db).all()
                XCTAssertEqual(qRecipients[0].$client.id, clientID)
                XCTAssertEqual(qRecipients[0].$questionnaire.id, qID)
            } catch {}
        })
    }
    
    func test_Create_WithoutAuthorization_Fails() async throws {
        let client = try await UserControllerTests().createExpectedUser(userType: .client, on: app.db)
        let clientID = try client.requireID()
        let unauthorizedToken = try await Token.create(for: client, on: app.db)
        let adminID = try admin.requireID()
        let input = Questionnaire.Input(title: expectedTitle,
                                        fields: expectedFields,
                                        adminID: adminID,
                                        clientIDs: [clientID]
        )
        
        try await app.test(.POST, baseURL, beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: unauthorizedToken.value)
            try req.content.encode(input)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.role"))
        })
    }
    
    func test_Create_WithoutAdmin_Fails() async throws {
        let client = try await  UserControllerTests().createExpectedUser(userType: .client, on: app.db)
        let clientID = try client.requireID()
        let input = Questionnaire.Input(title: expectedTitle,
                                        fields: expectedFields,
                                        adminID: clientID,
                                        clientIDs: [clientID]
        )
        try await app.test(.POST, baseURL, beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(input)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.userNotAdmin"))
        })
    }
    
    func test_Create_WithDuplicateFieldIndexes_Fails() async throws {
        let client = try await  UserControllerTests().createExpectedUser(userType: .client, on: app.db)
        let clientID = try client.requireID()
        let adminID = try admin.requireID()
        let input = Questionnaire.Input(title: expectedTitle,
                                        fields: wrongFields,
                                        adminID: adminID,
                                        clientIDs: [clientID]
        )
        
        try await app.test(.POST, baseURL, beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(input)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.duplicateFieldIndexes"))
        })
    }
}
