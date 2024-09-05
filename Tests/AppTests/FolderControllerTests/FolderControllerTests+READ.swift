//
//  FolderControllerTests+READ.swift
//  
//
//  Created by Raphaël Payet on 08/08/2024.
//

@testable import App
import XCTVapor
import Fluent
import Vapor

// MARK: - Get All
extension FolderControllerTests {
    func testGetAllWithDataSucceed() async throws {
        let process = try await FolderControllerTests().createExpectedFolder(with: adminID, on: app.db)
        try await app.test(.GET, baseURL) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let processus = try res.content.decode([Folder].self)
                XCTAssertEqual(processus.count, 1)
                XCTAssertEqual(processus[0].title, expectedTitle)
                XCTAssertEqual(processus[0].number, expectedNumber)
                XCTAssertEqual(processus[0].sleeve, expectedSleeve)
                XCTAssertEqual(process.title, expectedTitle)
                XCTAssertEqual(process.number, expectedNumber)
                XCTAssertEqual(process.sleeve, expectedSleeve)
            } catch { }
        }
    }
    
    func testGetAllWithoutDataSucceed() async throws {
        try await app.test(.GET, baseURL) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let processus = try res.content.decode([Folder].self)
                XCTAssertEqual(processus.count, 0)
            } catch { }
        }
    }
}
