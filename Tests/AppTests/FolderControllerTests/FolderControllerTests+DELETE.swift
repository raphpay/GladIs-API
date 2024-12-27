//
//  FolderControllerTests+DELETE.swift
//  
//
//  Created by Raphaël Payet on 08/08/2024.
//

@testable import App
import XCTVapor
import Fluent
import Vapor

// MARK: - Delete
extension FolderControllerTests {
    func test_Delete_Succeed() async throws {
        let folder = try await FolderControllerTests().createExpectedFolder(with: adminID, on: app.db)
        let folderID = try folder.requireID()
        
        try await app.test(.DELETE, "\(baseURL)/\(folderID)") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .noContent)
            do {
                let folderes = try await Folder.query(on: app.db).all()
                XCTAssertEqual(folderes.count, 0)
            } catch { }
        }
    }
    
    func test_Delete_WithIncorrectID_Fails() async throws {
        try await app.test(.DELETE, "\(baseURL)/12345") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingOrIncorrectFolderID"))
        }
    }
    
    func test_Delete_WithInexistantFolder_Fails() async throws {
        let falseID = UUID()
        
        try await app.test(.DELETE, "\(baseURL)/\(falseID)") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.folder"))
        }
    }
    
    func test_Delete_WithUnauthorizedRole_Fails() async throws {
        let unauthorizedUser = try await UserControllerTests().createExpectedUser(userType: .client, on: app.db)
        let unauthorizedToken = try await Token.create(for: unauthorizedUser, on: app.db)
        let folder = try await FolderControllerTests().createExpectedFolder(with: adminID, on: app.db)
        let folderID = try folder.requireID()
        
        try await app.test(.DELETE, "\(baseURL)/\(folderID)", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: unauthorizedToken.value)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .forbidden)
            XCTAssertTrue(res.body.string.contains("forbidden.userShouldBeAdmin"))
        })
    }
}

// MARK: - Delete All
extension FolderControllerTests {
    func test_DeleteAll_Succeed() async throws {
        let _ = try await FolderControllerTests().createExpectedFolder(with: adminID, on: app.db)
        
        try await app.test(.DELETE, "\(baseURL)/all") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .noContent)
            do {
                let folders = try await Folder.query(on: app.db).all()
                XCTAssertEqual(folders.count, 0)
            } catch { }
        }
    }
    
    func test_DeleteAll_WithUnauthorizedUser_Fails() async throws {
        let unauthorizedUser = try await UserControllerTests().createExpectedUser(userType: .client, on: app.db)
        let unauthorizedToken = try await Token.create(for: unauthorizedUser, on: app.db)
        let _ = try await FolderControllerTests().createExpectedFolder(with: adminID, on: app.db)
        
        try await app.test(.DELETE, "\(baseURL)/all", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: unauthorizedToken.value)
        }, afterResponse: { res async in
            // Then
            XCTAssertEqual(res.status, .forbidden)
            XCTAssertTrue(res.body.string.contains("forbidden.userShouldBeAdmin"))
        })
    }
}
