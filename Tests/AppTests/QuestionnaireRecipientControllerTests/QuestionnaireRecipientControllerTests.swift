//
//  QuestionnaireRecipientControllerTests.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 23/01/2025.
//

@testable import App
import XCTVapor
import Fluent

final class QuestionnaireRecipientControllerTests: XCTestCase {
    
    var app: Application!
    let baseURL = "api/questionnaires/recipients"
    var admin: User!
    var token: Token!
    var adminID: User.IDValue!
    var questionnaire: Questionnaire!
    var qID: Questionnaire.IDValue!
    var client: User!
    var clientID: User.IDValue!
    
    override func setUp() async throws {
        try await super.setUp()
        app = Application(.testing)
        try! await configure(app)
        admin = try await UserControllerTests().createExpectedAdmin(on: app.db)
        token = try await Token.create(for: admin, on: app.db)
        adminID = try admin.requireID()
        questionnaire = try await QuestionnaireControllerTests().createExpectedQuestionnaire(adminID: adminID, on: app.db)
        qID = try questionnaire.requireID()
        client = try await UserControllerTests().createExpectedUser(userType: .client, on: app.db)
        clientID = try client.requireID()
    }
    
    override func tearDown() async throws {
        try await User.deleteAll(on: app.db)
        try await token.delete(force: true, on: app.db)
        try await Questionnaire.query(on: app.db).all().delete(force: true, on: app.db)
        try await QuestionnaireRecipient.query(on: app.db).all().delete(force: true, on: app.db)
        // Required
        app.shutdown()
        try await super.tearDown()
    }
    
    // Expected Properties
}

