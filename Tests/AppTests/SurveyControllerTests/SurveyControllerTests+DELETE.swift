//
//  SurveyControllerTests+DELETE.swift
//
//
//  Created by Raphaël Payet on 29/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Remove
extension SurveyControllerTests {
    func testRemoveSurveySucceed() async throws {
        let admin = try await User.create(username: expectedAdminUsername, on: app.db)
        let token = try await Token.create(for: admin, on: app.db)
        let client = try await User.create(username: expectedUsername, on: app.db)
        let clientID = try client.requireID()
        
        let survey = try await Survey.create(value: expectedValue, clientID: clientID, on: app.db)
        let surveyID = try survey.requireID()
        
        let path = "\(baseRoute)/\(surveyID)"
        try app.test(.DELETE, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
        }
    }
    
    func testRemoveSurveyWithInexistantSurveyFails() async throws {
        let admin = try await User.create(username: expectedAdminUsername, on: app.db)
        let token = try await Token.create(for: admin, on: app.db)
        
        let path = "\(baseRoute)/12345"
        try app.test(.DELETE, path) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.survey"))
        }
    }
}

// MARK: - Remove All
extension SurveyControllerTests {
    func testRemoveAllSucceed() async throws {
        let admin = try await User.create(username: expectedAdminUsername, on: app.db)
        let token = try await Token.create(for: admin, on: app.db)
        let client = try await User.create(username: expectedUsername, on: app.db)
        let clientID = try client.requireID()
        
        let _ = try await Survey.create(value: expectedValue, clientID: clientID, on: app.db)
        
        try app.test(.DELETE, baseRoute) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
        }
    }
}
