//
//  DocumentActivityLogControllerTests.swift
//
//
//  Created by Raphaël Payet on 15/04/2024.
//

@testable import App
import XCTVapor

final class DocumentActivityLogControllerTests: XCTestCase {
    
    var app: Application!
    // Expected Properties
    let expectedUsername = "testuser"
    let expectedClientUsername = "expectedClientUsername"
    let expectedDocPath = "test/test"
    let expectedDocumentName = "Test Document"
    let expectedFormTitle = "Test Form"
    let expectedFormValue = "Test Value"
    let expectedAction: DocumentActivityLog.ActionEnum = .creation
    
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
