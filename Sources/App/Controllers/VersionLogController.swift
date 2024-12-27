//
//  VersionLogController.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 27/12/2024.
//

import Foundation
//
//  TokenController.swift
//
//
//  Created by Raphaël Payet on 09/02/2024.
//


import Fluent
import Vapor

struct VersionLogController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let versionLogs = routes.grouped("api", "versionLogs")
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = versionLogs.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        // Create
        tokenAuthGroup.post(use: create)
        // Read
        tokenAuthGroup.get(use: get)
        // Update
        // Delete
        tokenAuthGroup.delete("all", use: delete)
    }
    
    // MARK: - Create
    func create(req: Request) async throws -> VersionLog {
        let input = try req.content.decode(VersionLog.Input.self)
        let versionLog = input.toModel()
        
        if try await !VersionLog.query(on: req.db).all().isEmpty {
            throw Abort(.conflict, reason: "conflict.versionLogAlreadyExists")
        }
        
        try await versionLog.save(on: req.db)
        return versionLog
    }
    
    // MARK: - Read
    func get(req: Request) async throws -> VersionLog {
        guard let versionLog = try await VersionLog.query(on: req.db).first() else {
            throw Abort(.notFound, reason: "notFound.versionLog")
        }
        
        return versionLog
    }
    
    // MARK: - Delete
    func delete(req: Request) async throws -> HTTPResponseStatus {
        try await VersionLog.query(on: req.db).all().delete(force: true, on: req.db)
        return .noContent
    }
}

