//
//  EventControllerTests.swift
//
//
//  Created by Raphaël Payet on 15/04/2024.
//

@testable import App
import XCTVapor

final class EventControllerTests: XCTestCase {
    
    var app: Application!
    // Expected Properties
    let expectedUsername = "testUsername"
    let expectedEventName = "Event"
    
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
