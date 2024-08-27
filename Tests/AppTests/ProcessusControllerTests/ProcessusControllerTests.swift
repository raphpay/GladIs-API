//
//  FolderControllerTests.swift
//
//
//  Created by Raphaël Payet on 17/04/2024.
//

@testable import App
import XCTVapor

final class FolderControllerTests: XCTestCase {
    
    var app: Application!
    let baseURL = "api/folders"
    var admin: User!
    var adminID: User.IDValue!
    var token: Token!
    // Expected Properties
    let expectedAdminUsername = "expectedAdminUsername"
    // Process
    let expectedTitle = "expectedTitle"
    let expectedNumber = 1
    let expectedSleeve = Folder.Sleeve.systemQuality
    
    override func setUp() async throws {
        try await super.setUp()
        app = Application(.testing)
        try! await configure(app)
        admin = try await User.create(username: expectedAdminUsername, userType: .admin, on: app.db)
        adminID = try admin.requireID()
        token = try await Token.create(for: admin, on: app.db)
    }
    
    override func tearDown() async throws {
        try await User.deleteAll(on: app.db)
        admin.systemQualityFolders = nil
        admin.recordsFolders = nil
        try await admin.delete(force: true, on: app.db)
        adminID = nil
        try await token.delete(force: true, on: app.db)
        try await Folder.query(on: app.db).all().delete(force: true, on: app.db)
        app.shutdown()
        try await super.tearDown()
    }
}

