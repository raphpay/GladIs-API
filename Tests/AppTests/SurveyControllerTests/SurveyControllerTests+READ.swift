//
//  SurveyControllerTests+READ.swift
//
//
//  Created by Raphaël Payet on 29/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Get All
extension SurveyControllerTests {
    func testGetAllSurveyWithExistingSurveySuceed() async throws {
        try await Survey.deleteAll(on: app.db)
        let admin = try await User.create(username: expectedAdminUsername, on: app.db)
        let token = try await Token.create(for: admin, on: app.db)
        let client = try await User.create(username: expectedUsername, on: app.db)
        let clientID = try client.requireID()
        
        let _ = try await Survey.create(value: expectedValue, clientID: clientID, on: app.db)
        
        try app.test(.GET, baseRoute) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let surveys = try res.content.decode([Survey].self)
            XCTAssertEqual(surveys.count, 1)
            XCTAssertEqual(surveys[0].value, expectedValue)
            XCTAssertEqual(surveys[0].$client.id, clientID)
        }
    }
    
    func testGetAllSurveyWithoutSurveysSucceed() async throws {
        try await Survey.deleteAll(on: app.db)
        let admin = try await User.create(username: expectedAdminUsername, on: app.db)
        let token = try await Token.create(for: admin, on: app.db)
        
        try app.test(.GET, baseRoute) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let surveys = try res.content.decode([Survey].self)
            XCTAssertEqual(surveys.count, 0)
        }
    }
}
