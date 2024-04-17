//
//  TechnicalDocumentationTabControllerTests.swift
//
//
//  Created by Raphaël Payet on 17/04/2024.
//

@testable import App
import XCTVapor

final class TechnicalDocumentationTabControllerTests: XCTestCase {
    
    var app: Application!
    // Expected Properties
    let baseRoute = "api/technicalDocumentationTabs"
    let expectedName = "expectedName"
    let expectedArea = "expectedArea"
//    let expectedLastName = "expectedLastName"
//    let expectedPhoneNumber = "0612345678"
//    let expectedCompanyName = "Acme.inc"
//    let expectedEmail = "email@test.com"
//    // Pending User
//    let expectedPendingUserFirstName = "expectedPendingUserFirstName"
//    let expectedPendingUserLastName = "expectedPendingUserLastName"
//    let expectedPendingUserPhoneNumber = "0612345678"
//    let expectedPendingUserCompanyName = "Acme.inc"
//    let expectedPendingUserEmail = "expectedPendingUserEmail@test.com"
//    let expectedPendingUserProducts = "expectedPendingUserProducts"
//    let expectedPendingUserNumberOfEmployees = 12
//    let expectedPendingUserNumberOfUsers = 8
//    let expectedPendingUserSalesAmount: Double = 120000
//    let expectedPendingUserUsername = "expectedPendingUserUsername"
//    let expectedPendingUserModuleName = "expectedPendingUserModuleName"
//    let expectedPendingUserModuleIndex = 1
    let expectedAdminUsername = "expectedAdminUsername"
    
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
