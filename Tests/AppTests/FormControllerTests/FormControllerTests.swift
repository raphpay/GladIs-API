//
//  FormControllerTests.swift
//
//
//  Created by Raphaël Payet on 10/05/2024.
//

@testable import App
import XCTVapor

final class FormControllerTests: XCTestCase {
    
    var app: Application!
    // Expected Properties
    let baseRoute = "api/forms"
    let expectedTitle = "expectedTitle"
    let expectedValue = "expectedValue"
    let expectedPath = "path/expectedPath"
    let expectedClientID = "expectedClientID"
    let expectedUsername = "expectedUsername"
    let expectedClientUsername = "expectedClientUsername"
    let expectedUpdatedTitle = "expectedUpdatedTitle"
    let expectedUpdatedValue = "expectedUpdatedValue"
    
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

