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
extension ProcessusControllerTests {
    func testCreateSystemQualityProcessSucceed() async throws {
        let input = Processus.Input(title: expectedTitle, number: expectedNumber, userID: adminID, folder: .systemQuality)
        
        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                
                let processus = try res.content.decode(Processus.self)
                XCTAssertEqual(processus.title, expectedTitle)
                XCTAssertEqual(processus.number, expectedNumber)
                XCTAssertEqual(processus.folder, .systemQuality)
                
                let users = try await User.query(on: app.db).all()
                XCTAssertNotNil(users[0].systemQualityFolders)
                if let systemQualityFolders = users[0].systemQualityFolders {
                    XCTAssertEqual(systemQualityFolders.count, 1)
                    XCTAssertEqual(systemQualityFolders[0].title, processus.title)
                }
                XCTAssertNil(users[0].recordsFolders)
            } catch {}
        }
    }
    
    func testCreateSystemQualityFolderWithExistantFolderSucceed() async throws {
        let newProcessTitle = "expectedProcessusTitle"
        let newProcessNumber = 2
        let process = Processus(title: expectedTitle, number: expectedNumber, folder: .systemQuality, userID: adminID)
        let input = Processus.Input(title: newProcessTitle, number: 2, userID: adminID, folder: expectedFolder)
        try await saveProcess(to: admin, processus: [process], folder: expectedFolder, on: app.db)
        
        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let processus = try res.content.decode(Processus.self)
                XCTAssertEqual(processus.title, newProcessTitle)
                XCTAssertEqual(processus.number, newProcessNumber)
                XCTAssertEqual(processus.folder, expectedFolder)
                
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
        let input = Processus.Input(title: expectedTitle, number: expectedNumber, userID: adminID, folder: .record)
        
        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                
                let processus = try res.content.decode(Processus.self)
                XCTAssertEqual(processus.title, expectedTitle)
                XCTAssertEqual(processus.number, expectedNumber)
                XCTAssertEqual(processus.folder, .record)
                
                let users = try await User.query(on: app.db).all()
                XCTAssertNotNil(users[0].recordsFolders)
                if let recordsFolders = users[0].recordsFolders {
                    XCTAssertEqual(recordsFolders.count, 1)
                    XCTAssertEqual(recordsFolders[0].title, processus.title)
                }
                XCTAssertNil(users[0].systemQualityFolders)
            } catch {}
        }
    }
    
    func testCreateRecordFolderWithExistantFolderSucceed() async throws {
        let newProcessTitle = "expectedProcessusTitle"
        let newProcessNumber = 2
        let input = Processus.Input(title: newProcessTitle, number: 2, userID: adminID, folder: .record)
        let process = Processus(title: expectedTitle, number: expectedNumber, folder: .record, userID: adminID)
        try await saveProcess(to: admin, processus: [process], folder: .record, on: app.db)
        
        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .ok)
            do {
                let processus = try res.content.decode(Processus.self)
                XCTAssertEqual(processus.title, newProcessTitle)
                XCTAssertEqual(processus.number, newProcessNumber)
                XCTAssertEqual(processus.folder, .record)
                
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
        let input = Processus.Input(title: expectedTitle, number: expectedNumber, userID: UUID(), folder: expectedFolder)
        
        try await app.test(.POST, baseURL) { req in
            try req.content.encode(input)
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
}
