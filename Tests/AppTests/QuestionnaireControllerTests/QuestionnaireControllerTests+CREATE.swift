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
        let client = try await  UserControllerTests().createExpectedUser(userType: .client, on: app.db)
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
}
