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
    // Expected Properties
    let baseRoute = "api/users"
    let expectedFirstName = "expectedFirstName"
    let expectedLastName = "expectedLastName"
    let expectedPhoneNumber = "0612345678"
    let expectedEmail = "expectedEmail@test.com"
    let expectedPassword = "expectedPassword1("
    let expectedCompanyName = "expectedCompanyName"
    let expectedUsername = "expectedUsername"
    let expectedAdminUsername = "expectedAdminUsername"
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
    }
    
    override func tearDown() async throws {
        try await User.deleteAll(on: app.db)
        app.shutdown()
        try await super.tearDown()
    }
}

