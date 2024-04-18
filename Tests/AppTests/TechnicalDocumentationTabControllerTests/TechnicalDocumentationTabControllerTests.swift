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
