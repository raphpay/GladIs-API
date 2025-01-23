//
//  QuestionnaireControllerTests.swift
//
//
//  Created by Raphaël Payet on 17/04/2024.
//

@testable import App
import XCTVapor
import Fluent

final class QuestionnaireControllerTests: XCTestCase {
    
    var app: Application!
    let baseURL = "api/questionnaires"
    var admin: User!
    var adminID: User.IDValue!
    var token: Token!
    
    override func setUp() async throws {
        try await super.setUp()
        app = Application(.testing)
        try! await configure(app)
        admin = try await UserControllerTests().createExpectedAdmin(on: app.db)
        adminID = try admin.requireID()
        token = try await Token.create(for: admin, on: app.db)
    }
    
    override func tearDown() async throws {
        try await User.deleteAll(on: app.db)
        adminID = nil
        try await token.delete(force: true, on: app.db)
        try await Questionnaire.query(on: app.db).all().delete(force: true, on: app.db)
        try await QuestionnaireRecipient.query(on: app.db).all().delete(force: true, on: app.db)
        // Required
        app.shutdown()
        try await super.tearDown()
    }
    
    // Expected Properties
    let expectedTitle = "Test Questionnaire"
    let expectedFields = [Questionnaire.QField(key: "Test Field 1", index: 1),
                          Questionnaire.QField(key: "Test Field 2", index: 2)]
    // Wrong properties
    let wrongFields = [Questionnaire.QField(key: "Test Field 1", index: 1),
                       Questionnaire.QField(key: "Test Field 2", index: 1)]
}

