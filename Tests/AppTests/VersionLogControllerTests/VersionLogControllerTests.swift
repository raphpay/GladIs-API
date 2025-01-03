//
//  VersionLogControllerTests.swift
//
//
//  Created by Raphaël Payet on 17/04/2024.
//

@testable import App
import XCTVapor
import Fluent

final class VersionLogControllerTests: XCTestCase {
    
    var app: Application!
    let baseURL = "api/versionLogs"
    var admin: User!
    var adminID: User.IDValue!
    var token: Token!
    
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
        adminID = nil
        try await token.delete(force: true, on: app.db)
        try await VersionLog.deleteAll(on: app.db)
        app.shutdown()
        try await super.tearDown()
    }
    
    // Expected Properties
    let expectedCurrentVersion = "1.2.3"
    let expectedMinimumVersion = "1.2.0"
    let expectedSupportedClientVersions = ["1.0.0", "1.1.0"]
}

