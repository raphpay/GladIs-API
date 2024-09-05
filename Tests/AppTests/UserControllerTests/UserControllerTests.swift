//
//  UserControllerTests.swift
//
//
//  Created by Raphaël Payet on 17/04/2024.
//

@testable import App
import XCTVapor

final class UserControllerTests: XCTestCase {
    
    var app: Application!
    var admin: User!
    var adminID: UUID!
    var token: Token!
    // Admin
    let expectedAdminFirstName = "expectedAdminFirstName"
    let expectedAdminLastName = "expectedAdminLastName"
    let expectedAdminEmail = "expectedAdminEmail"
    let expectedAdminPhoneNumber = "0612345678"
    let expectedAdminUsername = "expectedAdminUsername"
    // Expected Properties
    let baseRoute = "api/users"
    let expectedFirstName = "expectedFirstName"
    let expectedLastName = "expectedLastName"
    let expectedPhoneNumber = "0612345678"
    let expectedEmail = "expectedEmail@test.com"
    let expectedPassword = "expectedPassword1("
    let expectedCompanyName = "expectedCompanyName"
    let expectedUsername = "expectedUsername"
    let expectedClientUsername = "expectedClientUsername"
    // Module
    let expectedModuleName = "expectedModuleName"
    let expectedModuleIndex = 1
    // Doc Tab
    let expectedDocTabName = "expectedDocTabName"
    let expectedDocTabArea = "expectedDocTabArea"
    // Message
    let expectedMessageTitle = "expectedMessageTitle"
    let expectedMessageContent = "expectedMessageContent"
    
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
        try await admin.delete(force: true, on: app.db)
        try await token.delete(force: true, on: app.db)
        app.shutdown()
        try await super.tearDown()
    }
}

