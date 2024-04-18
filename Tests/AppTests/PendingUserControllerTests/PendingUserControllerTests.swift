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
    // Expected Properties
    let baseRoute = "api/pendingUsers"
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
    }
    
    override func tearDown() {
        app.shutdown()
        super.tearDown()
    }
}
