//
//  ProcessControllerTests+CREATE.swift
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
    func testCreateSystemQualityProcessSucceed() async throws {
        let input = Folder.Input(title: expectedTitle, number: expectedNumber, userID: adminID, sleeve: .systemQuality, path: expectedPath)
        
        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let folder = try res.content.decode(Folder.self)
                XCTAssertEqual(folder.title, expectedTitle)
                XCTAssertEqual(folder.number, expectedNumber)
                XCTAssertEqual(folder.sleeve, .systemQuality)
                
                let users = try await User.query(on: app.db).all()
                XCTAssertNotNil(users[0].systemQualityFolders)
                if let systemQualityFolders = users[0].systemQualityFolders {
                    XCTAssertEqual(systemQualityFolders.count, 1)
                    XCTAssertEqual(systemQualityFolders[0].title, folder.title)
                }
                XCTAssertNil(users[0].recordsFolders)
            } catch {}
        }
    }
    
    func testCreateSystemQualityFolderWithExistantFolderSucceed() async throws {
        let newProcessTitle = "expectedFolderTitle"
        let newProcessNumber = 2
        let folder = Folder(title: expectedTitle, number: expectedNumber, sleeve: .systemQuality, userID: adminID)
        let input = Folder.Input(title: newProcessTitle, number: 2, userID: adminID, sleeve: expectedSleeve, path: expectedPath)
        try await saveProcess(to: admin, folder: [folder], sleeve: expectedSleeve, on: app.db)
        
        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let folder = try res.content.decode(Folder.self)
                XCTAssertEqual(folder.title, newProcessTitle)
                XCTAssertEqual(folder.number, newProcessNumber)
                XCTAssertEqual(folder.sleeve, expectedSleeve)
                
                let users = try await User.query(on: app.db).all()
                XCTAssertNotNil(users[0].systemQualityFolders)
                if let systemQualityFolders = users[0].systemQualityFolders {
                    XCTAssertEqual(systemQualityFolders.count, 2)
                    XCTAssertEqual(systemQualityFolders[0].title, expectedTitle)
                    XCTAssertEqual(systemQualityFolders[1].title, newProcessTitle)
                }
                XCTAssertNil(users[0].recordsFolders)
            } catch {}
        }
    }
    
    func testCreateRecordProcessSucceed() async throws {
        let input = Folder.Input(title: expectedTitle, number: expectedNumber, userID: adminID, sleeve: .record, path: expectedPath)
        
        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                
                let folder = try res.content.decode(Folder.self)
                XCTAssertEqual(folder.title, expectedTitle)
                XCTAssertEqual(folder.number, expectedNumber)
                XCTAssertEqual(folder.sleeve, .record)
                
                let users = try await User.query(on: app.db).all()
                XCTAssertNotNil(users[0].recordsFolders)
                if let recordsFolders = users[0].recordsFolders {
                    XCTAssertEqual(recordsFolders.count, 1)
                    XCTAssertEqual(recordsFolders[0].title, folder.title)
                }
                XCTAssertNil(users[0].systemQualityFolders)
            } catch {}
        }
    }
    
    func testCreateRecordFolderWithExistantFolderSucceed() async throws {
        let newProcessTitle = "expectedFolderTitle"
        let newProcessNumber = 2
        let input = Folder.Input(title: newProcessTitle, number: 2, userID: adminID, sleeve: .record, path: expectedPath)
        let folder = Folder(title: expectedTitle, number: expectedNumber, sleeve: .record, userID: adminID)
        try await saveProcess(to: admin, folder: [folder], sleeve: .record, on: app.db)
        
        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let folder = try res.content.decode(Folder.self)
                XCTAssertEqual(folder.title, newProcessTitle)
                XCTAssertEqual(folder.number, newProcessNumber)
                XCTAssertEqual(folder.sleeve, .record)
                
                let users = try await User.query(on: app.db).all()
                XCTAssertNotNil(users[0].recordsFolders)
                if let recordsFolders = users[0].recordsFolders {
                    XCTAssertEqual(recordsFolders.count, 2)
                    XCTAssertEqual(recordsFolders[0].title, expectedTitle)
                    XCTAssertEqual(recordsFolders[1].title, newProcessTitle)
                }
                XCTAssertNil(users[0].systemQualityFolders)
            } catch {}
        }
    }
    
    func testCreateWithInexistantUserFails() async throws {
        let input = Folder.Input(title: expectedTitle, number: expectedNumber, userID: UUID(), sleeve: expectedSleeve, path: expectedPath)
        
        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
    
    func testCreateWithSameNumberSucceed() async throws {
        let _ = try await FolderControllerTests().createExpectedFolder(for: admin, in: .systemQuality, on: app.db)
        let input = Folder.Input(title: "\(expectedTitle)2", number: expectedNumber, userID: adminID, sleeve: expectedSleeve, path: expectedPath)
        
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
                
                let users = try await User.query(on: app.db).all()
                XCTAssertNotNil(users[0].systemQualityFolders)
                if let systemQualityFolders = users[0].systemQualityFolders {
                    XCTAssertEqual(systemQualityFolders.count, 2)
                    XCTAssertEqual(systemQualityFolders[1].title, "\(expectedTitle)2")
                }
                XCTAssertNil(users[0].recordsFolders)
            } catch {}
        }
    }
}

// MARK: - Create Multiple
extension FolderControllerTests {
    func testCreateMultipleSucceed() async throws {
        let folderInput = Folder.Input(title: expectedTitle, number: expectedNumber, userID: adminID, sleeve: expectedSleeve, path: expectedPath)
        let folderInputTwo = Folder.Input(title: "\(expectedTitle)2", number: expectedNumber + 1, userID: adminID, sleeve: expectedSleeve, path: expectedPath)
        let input = Folder.MultipleInput(inputs: [folderInput, folderInputTwo], userID: adminID)
        
        try await app.test(.POST, "\(baseURL)/multiple") { req in
            try req.content.encode(input)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let folder = try res.content.decode([Folder].self)
                XCTAssertEqual(folder[0].title, expectedTitle)
                XCTAssertEqual(folder[0].number, expectedNumber)
                XCTAssertEqual(folder[0].sleeve, .systemQuality)
                
                XCTAssertEqual(folder[1].title, "\(expectedTitle)2")
                XCTAssertEqual(folder[1].number, expectedNumber + 1)
                XCTAssertEqual(folder[1].sleeve, .systemQuality)
                
                let users = try await User.query(on: app.db).all()
                XCTAssertNotNil(users[0].systemQualityFolders)
                if let systemQualityFolders = users[0].systemQualityFolders {
                    XCTAssertEqual(systemQualityFolders.count, 2)
                    XCTAssertEqual(systemQualityFolders[0].title, folder[0].title)
                }
                XCTAssertNil(users[0].recordsFolders)
            } catch {}
        }
    }
}
