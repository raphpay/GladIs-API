//
//  FolderControllerTests+CREATE.swift
//
//
//  Created by Raphaël Payet on 08/08/2024.
//

@testable import App
import XCTVapor
import Fluent
import Vapor

// MARK: - Create
extension FolderControllerTests {
    func test_Create_Succeed() async throws {
        let input = Folder.Input(title: expectedTitle,
                                 number: expectedNumber,
                                 userID: adminID,
                                 sleeve: expectedSleeve,
                                 path: expectedPath,
                                 category: expectedCategory)
        
        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let folder = try res.content.decode(Folder.self)
                
                XCTAssertEqual(folder.title, expectedTitle)
                XCTAssertEqual(folder.number, expectedNumber)
                XCTAssertEqual(folder.sleeve, expectedSleeve)
                XCTAssertEqual(folder.category, expectedCategory)
                XCTAssertEqual(folder.path, expectedPath)
                XCTAssertEqual(folder.$user.id, adminID)
            } catch {}
        }
    }
    
    func test_Create_WithSameNumber_Succeed() async throws {
        let _ = try await FolderControllerTests().createExpectedFolder(for: admin, in: .systemQuality, on: app.db)
        let input = Folder.Input(title: "\(expectedTitle)2",
                                 number: expectedNumber,
                                 userID: adminID,
                                 sleeve: expectedSleeve,
                                 path: expectedPath,
                                 category: expectedCategory
        )
        
        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let folder = try res.content.decode(Folder.self)
                XCTAssertEqual(folder.title, "\(expectedTitle)2")
                XCTAssertEqual(folder.number, expectedNumber + 1)
                XCTAssertEqual(folder.sleeve, .systemQuality)
                XCTAssertEqual(folder.sleeve, expectedSleeve)
                XCTAssertEqual(folder.category, expectedCategory)
                XCTAssertEqual(folder.path, expectedPath)
            } catch {}
        }
    }
    
    func test_Create_WithInexistantUser_Fails() async throws {
        let input = Folder.Input(title: expectedTitle,
                                 number: expectedNumber,
                                 userID: UUID(),
                                 sleeve: expectedSleeve,
                                 path: expectedPath,
                                 category: expectedCategory
        )
        
        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
}

// MARK: - Create Multiple
extension FolderControllerTests {
    func test_CreateMultiple_Succeed() async throws {
        let folderInput = Folder.Input(title: expectedTitle,
                                       number: expectedNumber,
                                       userID: adminID,
                                       sleeve: expectedSleeve,
                                       path: expectedPath,
                                       category: expectedCategory
        )
        let folderInputTwo = Folder.Input(title: "\(expectedTitle)2",
                                          number: expectedNumber + 1,
                                          userID: adminID,
                                          sleeve: expectedSleeve,
                                          path: expectedPath,
                                          category: expectedCategory
        )
        let input = Folder.MultipleInput(inputs: [folderInput, folderInputTwo], userID: adminID)
        
        try await app.test(.POST, "\(baseURL)/multiple") { req in
            try req.content.encode(input)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let folders = try res.content.decode([Folder].self)
                XCTAssertEqual(folders[0].title, expectedTitle)
                XCTAssertEqual(folders[0].number, expectedNumber)
                XCTAssertEqual(folders[0].sleeve, expectedSleeve)
                XCTAssertEqual(folders[0].category, expectedCategory)
                XCTAssertEqual(folders[0].path, expectedPath)
                
                XCTAssertEqual(folders[1].title, "\(expectedTitle)2")
                XCTAssertEqual(folders[1].number, expectedNumber + 1)
                XCTAssertEqual(folders[1].sleeve, expectedSleeve)
                XCTAssertEqual(folders[1].path, expectedPath)
                XCTAssertEqual(folders[1].category, expectedCategory)
            } catch {}
        }
    }
    
    func test_CreateMultiple_WithInexistantUser_Fails() async throws {
        let folderInput = Folder.Input(title: expectedTitle,
                                       number: expectedNumber,
                                       userID: adminID,
                                       sleeve: expectedSleeve,
                                       path: expectedPath,
                                       category: expectedCategory
        )
        let folderInputTwo = Folder.Input(title: "\(expectedTitle)2",
                                          number: expectedNumber + 1,
                                          userID: adminID,
                                          sleeve: expectedSleeve,
                                          path: expectedPath,
                                          category: expectedCategory
        )
        let input = Folder.MultipleInput(inputs: [folderInput, folderInputTwo], userID: UUID())
        
        try await app.test(.POST, "\(baseURL)/multiple", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(input)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        })
    }
}
