//
//  SurveyControllerTests+CREATE.swift
//
//
//  Created by Raphaël Payet on 29/04/2024.
//

@testable import App
import XCTVapor

// MARK: - Create
extension SurveyControllerTests {
    func testCreateSurveySuceed() async throws {
        let client = try await User.create(username: expectedUsername, userType: .client, on: app.db)
        let token = try await Token.create(for: client, on: app.db)
        let clientID = try client.requireID()
        let input = Survey.Input(value: expectedValue, clientID: clientID)
        
        try app.test(.POST, baseRoute) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(input)
        } afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let createdSurvey = try res.content.decode(Survey.self)
            XCTAssertEqual(createdSurvey.$client.id, clientID)
            XCTAssertEqual(createdSurvey.value, expectedValue)
        }
    }
}
