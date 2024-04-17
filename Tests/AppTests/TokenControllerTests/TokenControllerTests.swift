//
//  TokenControllerTests.swift
//
//
//  Created by Raphaël Payet on 17/04/2024.
//

@testable import App
import XCTVapor

final class TokenControllerTests: XCTestCase {
    
    var app: Application!
    // Expected Properties
    let baseRoute = "api/tokens"
    let expectedUsername = "expectedUsername"
    let expectedPassword = "expectedPassword1("
    
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
