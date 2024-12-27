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
    func test_GetAll_Succeed() async throws {
        let folder = try await FolderControllerTests().createExpectedFolder(with: adminID, on: app.db)
        try await app.test(.GET, baseURL) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let folders = try res.content.decode([Folder].self)
                XCTAssertEqual(folders.count, 1)
                XCTAssertEqual(folders[0].title, expectedTitle)
                XCTAssertEqual(folders[0].number, expectedNumber)
                XCTAssertEqual(folders[0].sleeve, expectedSleeve)
                XCTAssertEqual(folder.title, expectedTitle)
                XCTAssertEqual(folder.number, expectedNumber)
                XCTAssertEqual(folder.sleeve, expectedSleeve)
            } catch { }
        }
    }
}
