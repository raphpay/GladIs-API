//
//  PendingUserControllerTests.swift
//
//
//  Created by Raphaël Payet on 16/04/2024.
//

@testable import App
import XCTVapor

final class PendingUserControllerTests: XCTestCase {
    
    var app: Application!
    let baseRoute = "api/pendingUsers"
    var admin: User!
    var adminID: User.IDValue!
    var token: Token!
    // Expected Properties
    let expectedFirstName = "expectedFirstName"
    let expectedLastName = "expectedLastName"
    let expectedPhoneNumber = "0612345678"
    let expectedCompanyName = "Acme.inc"
    let expectedEmail = "email@test.com"
    let expectedProducts = "tests"
    let expectedNumberOfEmployees = 12
    let expectedNumberOfUsers = 8
    let expectedSalesAmount: Double = 120000
    let expectedUsername = "expectedUsername"
    let expectedModuleName = "expectedModuleName"
    let expectedModuleIndex = 1
    
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
        try await token.delete(force: true, on: app.db)
        try await User.deleteAll(on: app.db)
        try await PendingUser.deleteAll(on: app.db)
        app.shutdown()
        try await super.tearDown()
    }
}
