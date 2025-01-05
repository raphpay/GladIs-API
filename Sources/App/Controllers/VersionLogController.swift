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
        
        // Read
        versionLogs.get(use: get)
        
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = versionLogs.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        // Create
        tokenAuthGroup.post(use: create)
        // Update
        tokenAuthGroup.put(use: update)
        // Delete
        tokenAuthGroup.delete("all", use: delete)
    }
    
    // MARK: - Create
    func create(req: Request) async throws -> VersionLog {
        try Utils.checkRole(on: req, allowedRoles: [.admin])
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
    
    // MARK: - Update
    func update(req: Request) async throws -> VersionLog {
        try Utils.checkRole(on: req, allowedRoles: [.admin])
        let versionLog = try await get(req: req)
        let input = try req.content.decode(VersionLog.UpdateInput.self)
        
        let updatedVersionLog = try input.update(versionLog)
        try await updatedVersionLog.update(on: req.db)
        
        return updatedVersionLog
    }
    
    // MARK: - Delete
    func delete(req: Request) async throws -> HTTPResponseStatus {
        try Utils.checkRole(on: req, allowedRoles: [.admin])
        try await VersionLog.query(on: req.db).all().delete(force: true, on: req.db)
        return .noContent
    }
}

