//
//  VersionLogControllerTests+READ.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 27/12/2024.
//

@testable import App
import XCTVapor
import Fluent
import Vapor

// MARK: - Get
extension VersionLogControllerTests {
    func test_Get_Succeed() async throws {
        let _ = try await VersionLogControllerTests().createExpectedVersionLog(on: app.db)
        
        try await app.test(.GET, baseURL, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .ok)
            do {
                let versionLog = try res.content.decode(VersionLog.self)
                XCTAssertEqual(versionLog.currentVersion, expectedCurrentVersion)
                XCTAssertEqual(versionLog.minimumClientVersion, expectedMinimumVersion)
            } catch {}
        })
    }
    
    func test_Get_WithInexistantVersionLog_Fails() async throws {
        try await app.test(.GET, baseURL, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.versionLog"))
        })
    }
}
