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
    func testDeleteSucceed() async throws {
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
    
    func testDeleteWithIncorrectIDFails() async throws {
        try await app.test(.DELETE, "\(baseURL)/12345") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingOrIncorrectFolderID"))
        }
    }
    
    func testDeleteWithInexistantFolderFails() async throws {
        let falseID = UUID()
        
        try await app.test(.DELETE, "\(baseURL)/\(falseID)") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.folder"))
        }
    }
    
    func testDeleteWithInexistantUserFails() async throws {
        let falseUserID = UUID()
        let folder = try await FolderControllerTests().createExpectedFolder(with: falseUserID, on: app.db)
        let folderID = try folder.requireID()
        
        try await app.test(.DELETE, "\(baseURL)/\(folderID)") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
}

// MARK: - Delete All For User
extension FolderControllerTests {
    func testDeleteAllForUserSucceed() async throws {
        let _ = try await FolderControllerTests().createExpectedFolder(with: adminID, on: app.db)
        
        try await app.test(.DELETE, "\(baseURL)/all/for/\(adminID!)") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .noContent)
            do {
                let folderes = try await Folder.query(on: app.db).all()
                XCTAssertEqual(folderes.count, 0)
            } catch { }
        }
    }
    
    func testDeleteAllWithIncorrectIDFails() async throws {
        try await app.test(.DELETE, "\(baseURL)/all/for/12345") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingOrIncorrectUserID"))
        }
    }
    
    func testDeleteAllWithInexistantUserFails() async throws {
        let falseUserID = UUID()
        try await app.test(.DELETE, "\(baseURL)/all/for/\(falseUserID)") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
}

// MARK: - Delete All
extension FolderControllerTests {
    func testDeleteAll() async throws {
        let folder = try await FolderControllerTests().createExpectedFolder(with: adminID, on: app.db)
        
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
}
