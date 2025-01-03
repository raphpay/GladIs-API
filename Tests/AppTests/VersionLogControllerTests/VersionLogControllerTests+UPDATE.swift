//
//  VersionLogControllerTests+UPDATE.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 03/01/2025.
//

@testable import App
import XCTVapor
import Fluent
import Vapor

// MARK: - Create
extension VersionLogControllerTests {
    func test_Update_Succeed() async throws {
        let versionLog = try await VersionLogControllerTests().createExpectedVersionLog(on: app.db)
        
        let newVersion = "1.2.4"
        let newMinimumClientVersion = "1.2.1"
        let input = VersionLog.UpdateInput(currentVersion: newVersion,
                                           minimumClientVersion: newMinimumClientVersion)
        
        try await app.test(.PUT, baseURL, beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(input)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .ok)
            do {
                let updatedVersionLog = try res.content.decode(VersionLog.self)
                XCTAssertEqual(updatedVersionLog.currentVersion, newVersion)
                XCTAssertEqual(updatedVersionLog.minimumClientVersion, newMinimumClientVersion)
            } catch { }
        })
    }
    
    func test_Update_WithUnauthorizedRole_Fails() async throws {
        let versionLog = try await VersionLogControllerTests().createExpectedVersionLog(on: app.db)
        
        let newVersion = "1.2.4"
        let newMinimumClientVersion = "1.2.1"
        let input = VersionLog.UpdateInput(currentVersion: newVersion,
                                           minimumClientVersion: newMinimumClientVersion)
        
        let unauthorizedUser = try await UserControllerTests().createExpectedUser(userType: .client, on: app.db)
        let unauthorizedToken = try await Token.create(for: unauthorizedUser, on: app.db)
        
        try await app.test(.PUT, baseURL, beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: unauthorizedToken.value)
            try req.content.encode(input)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertTrue(res.body.string.contains("unauthorized.role"))
        })
    }
    
    func test_Update_WithInexistantVersionLog_Fails() async throws {
        let newVersion = "1.2.4"
        let newMinimumClientVersion = "1.2.1"
        let input = VersionLog.UpdateInput(currentVersion: newVersion,
                                           minimumClientVersion: newMinimumClientVersion)
        
        try await app.test(.PUT, baseURL, beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(input)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.versionLog"))
        })
    }
    
    func test_Update_WithRegressionOnCurrentVersion_Fails() async throws {
        let versionLog = try await VersionLogControllerTests().createExpectedVersionLog(on: app.db)
        
        let newVersion = "1.2.2"
        let newMinimumClientVersion = "1.2.1"
        let input = VersionLog.UpdateInput(currentVersion: newVersion,
                                           minimumClientVersion: newMinimumClientVersion)
        try await app.test(.PUT, baseURL, beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(input)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.currentVersionRegression"))
        })
    }
    
    func test_Update_WithRegressionOnMinimumClientVersion_Fails() async throws {
        let versionLog = try await VersionLogControllerTests().createExpectedVersionLog(on: app.db)
        
        let newVersion = "1.2.4"
        let newMinimumClientVersion = "1.1.0"
        let input = VersionLog.UpdateInput(currentVersion: newVersion,
                                           minimumClientVersion: newMinimumClientVersion)
        try await app.test(.PUT, baseURL, beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(input)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.minimumClientVersionRegression"))
        })
    }
}
