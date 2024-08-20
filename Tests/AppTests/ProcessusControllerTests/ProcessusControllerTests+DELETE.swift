//
//  ProcessusControllerTests+DELETE.swift
//  
//
//  Created by Raphaël Payet on 08/08/2024.
//

@testable import App
import XCTVapor
import Fluent
import Vapor

// MARK: - Delete
extension ProcessusControllerTests {
    func testDeleteSucceed() async throws {
        let processus = try await ProcessusControllerTests().createExpectedProcessus(with: adminID, on: app.db)
        let processusID = try processus.requireID()
        
        try await app.test(.DELETE, "\(baseURL)/\(processusID)") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .noContent)
            do {
                let processes = try await Processus.query(on: app.db).all()
                XCTAssertEqual(processes.count, 0)
            } catch { }
        }
    }
    
    func testDeleteWithIncorrectIDFails() async throws {
        try await app.test(.DELETE, "\(baseURL)/12345") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertTrue(res.body.string.contains("badRequest.missingOrIncorrectProcessusID"))
        }
    }
    
    func testDeleteWithInexistantProcessusFails() async throws {
        let falseID = UUID()
        
        try await app.test(.DELETE, "\(baseURL)/\(falseID)") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.processus"))
        }
    }
    
    func testDeleteWithInexistantUserFails() async throws {
        let falseUserID = UUID()
        let processus = try await ProcessusControllerTests().createExpectedProcessus(with: falseUserID, on: app.db)
        let processusID = try processus.requireID()
        
        try await app.test(.DELETE, "\(baseURL)/\(processusID)") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertTrue(res.body.string.contains("notFound.user"))
        }
    }
}

// MARK: - Delete All For User
extension ProcessusControllerTests {
    func testDeleteAllForUserSucceed() async throws {
        let _ = try await ProcessusControllerTests().createExpectedProcessus(with: adminID, on: app.db)
        
        try await app.test(.DELETE, "\(baseURL)/all/for/\(adminID!)") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .noContent)
            do {
                let processes = try await Processus.query(on: app.db).all()
                XCTAssertEqual(processes.count, 0)
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
extension ProcessusControllerTests {
    func testDeleteAll() async throws {
        let processus = try await ProcessusControllerTests().createExpectedProcessus(with: adminID, on: app.db)
        
        try await app.test(.DELETE, "\(baseURL)/all") { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token.value)
        } afterResponse: { res async in
            XCTAssertEqual(res.status, .noContent)
            do {
                let processes = try await Processus.query(on: app.db).all()
                XCTAssertEqual(processes.count, 0)
            } catch { }
        }
    }
}
