//
//  VersionLogControllerTests+CREATE.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 27/12/2024.
//

@testable import App
import XCTVapor
import Fluent
import Vapor

// MARK: - Create
extension VersionLogControllerTests {
    func test_Create_Succeed() async throws {
        let input = VersionLog.Input(currentVersion: expectedCurrentVersion,
                                     supportedClientVersions: expectedSupportedClientVersions,
                                     minimumClientVersion: expectedMinimumVersion)
        try await app.test(.POST, baseURL, beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(input)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .ok)
            do {
                let versionLog = try res.content.decode(VersionLog.self)
                XCTAssertEqual(versionLog.currentVersion, expectedCurrentVersion)
                XCTAssertEqual(versionLog.supportedClientVersions, expectedSupportedClientVersions)
                XCTAssertEqual(versionLog.minimumClientVersion, expectedMinimumVersion)
            } catch {}
        })
    }
    
    func test_Create_WithUnauthorizedRole_Fails() async throws {
        let input = VersionLog.Input(currentVersion: expectedCurrentVersion,
                                     supportedClientVersions: expectedSupportedClientVersions,
                                     minimumClientVersion: expectedMinimumVersion)
        let unauthorizedUser = try await UserControllerTests().createExpectedUser(userType: .client, on: app.db)
        let unauthorizedToken = try await Token.create(for: unauthorizedUser, on: app.db)
        
        try await app.test(.POST, baseURL, beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: unauthorizedToken.value)
            try req.content.encode(input)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.role"))
        })
    }
    
    func test_Create_WithAlreadyExistingVersionLog_Fails() async throws {
        let _ = try await VersionLogControllerTests().createExpectedVersionLog(on: app.db)
        let input = VersionLog.Input(currentVersion: expectedCurrentVersion,
                                     supportedClientVersions: expectedSupportedClientVersions,
                                     minimumClientVersion: expectedMinimumVersion)
        try await app.test(.POST, baseURL, beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(input)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .conflict)
            XCTAssertTrue(res.body.string.contains("conflict.versionLogAlreadyExists"))
        })
    }
}
