//
//  SurveyControllerTests+UPDATE.swift
//
//
//  Created by Raphaël Payet on 29/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Update
extension SurveyControllerTests {
    func testUpdateSurveySucceed() async throws {
        let admin = try await User.create(username: expectedAdminUsername, on: app.db)
        let token = try await Token.create(for: admin, on: app.db)
        let client = try await User.create(username: expectedUsername, on: app.db)
        let clientID = try client.requireID()
        let survey = try await Survey.create(value: expectedValue, clientID: clientID, on: app.db)
        let surveyID = try survey.requireID()

        let updatedSurveyValue = "new value"
        let updateInput = Survey.UpdateInput(value: updatedSurveyValue)

        let path = "\(baseRoute)/\(surveyID)"
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(updateInput)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let survey = try res.content.decode(Survey.self)
            XCTAssertEqual(survey.value, updatedSurveyValue)
            XCTAssertEqual(survey.$client.id, clientID)
        }
    }
    
    func testUpdateSurveyWithInexistantSurveyFails() async throws {
        let admin = try await User.create(username: expectedAdminUsername, on: app.db)
        let token = try await Token.create(for: admin, on: app.db)
        let updateValue = Survey.UpdateInput(value: "new value")

        let path = "\(baseRoute)/12345"
        try app.test(.PUT, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(updateValue)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.survey"))
        }
    }
}
