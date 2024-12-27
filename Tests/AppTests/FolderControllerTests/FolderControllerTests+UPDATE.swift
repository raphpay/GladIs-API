//
//  FolderControllerTests+UPDATE.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 27/12/2024.
//

@testable import App
import XCTVapor
import Fluent
import Vapor

// MARK: - Update
extension FolderControllerTests {
    func test_Update_Succeed() async throws {
        let folder = try await FolderControllerTests().createExpectedFolder(with: adminID, on: app.db)
        let folderID = try folder.requireID()
        
        let newTitle = "newTitle"
        let newNumber = 2
        let newPath = "newPath"
        let newCategory = Folder.Category.process
        let updateInput = Folder.UpdateInput(title: newTitle,
                                             number: newNumber,
                                             path: newPath,
                                             category: newCategory)
        
        try await app.test(.PUT, "\(baseURL)/\(folderID)") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(updateInput)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let updatedFolder = try res.content.decode(Folder.self)
                XCTAssertEqual(updatedFolder.title, newTitle)
                XCTAssertEqual(updatedFolder.number, newNumber)
                XCTAssertEqual(updatedFolder.sleeve, expectedSleeve)
                XCTAssertEqual(updatedFolder.category, newCategory)
                XCTAssertEqual(updatedFolder.path, newPath)
            } catch { }
        }
    }
    
    func test_Update_WithIncorrectFolderID_Fails() async throws {
        let folder = try await FolderControllerTests().createExpectedFolder(with: adminID, on: app.db)
        
        let newTitle = "newTitle"
        let newNumber = 2
        let newPath = "newPath"
        let newCategory = Folder.Category.process
        let updateInput = Folder.UpdateInput(title: newTitle,
                                             number: newNumber,
                                             path: newPath,
                                             category: newCategory)
        
        try await app.test(.PUT, "\(baseURL)/12345", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(updateInput)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingOrIncorrectFolderID"))
        })
    }
    
    func test_Update_WithInexistantFolder_Fails() async throws {
        let folder = try await FolderControllerTests().createExpectedFolder(with: adminID, on: app.db)
        
        let newTitle = "newTitle"
        let newNumber = 2
        let newPath = "newPath"
        let newCategory = Folder.Category.process
        let updateInput = Folder.UpdateInput(title: newTitle,
                                             number: newNumber,
                                             path: newPath,
                                             category: newCategory)
        
        try await app.test(.PUT, "\(baseURL)/\(UUID())", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
            try req.content.encode(updateInput)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.folder"))
        })
    }
}
