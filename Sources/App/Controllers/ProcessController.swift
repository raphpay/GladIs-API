//
//  ProcessController.swift
//  
//
//  Created by Raphaël Payet on 06/08/2024.
//

import Fluent
import Vapor

struct ProcessController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let processes = routes.grouped("api", "processes")
        // Token Protected
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = processes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        // Create
        tokenAuthGroup.post(use: create)
        // Read
        tokenAuthGroup.get(use: getAll)
        // Delete
        tokenAuthGroup.delete(":userID", use: deleteAllForUser)
    }
    
    // MARK: - Create
    let logger = Logger(label: "process")
    func create(req: Request) async throws -> Process {
        let input = try req.content.decode(Process.Input.self)
        let user = try await input.validate(on: req.db)
        let process = input.toModel()
        
        try await process.save(on: req.db)
        
        if process.folder == .systemQuality {
            if var systemQualityFolders = user.systemQualityFolders {
                systemQualityFolders.append(process)
                logger.info("systemQualityFolders \(systemQualityFolders)")
                user.systemQualityFolders = systemQualityFolders
            } else {
                user.systemQualityFolders = [process]
            }
            try await user.update(on: req.db)
        } else if process.folder == .record {
            if var records = user.recordsFolders {
                records.append(process)
                user.recordsFolders = records
            } else {
                user.recordsFolders = [process]
            }
            try await user.update(on: req.db)
        }
        return process
    }
    
    // MARK: - READ
    @Sendable
    func getAll(req: Request) async throws -> [Process] {
        try await Process.query(on: req.db).all()
    }
    // MARK: - DELETE
    @Sendable
    func deleteAllForUser(req: Request) async throws -> HTTPResponseStatus {
        // TODO: Refactor this guard statement
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.user")
        }
        
        user.recordsFolders?.removeAll()
        user.systemQualityFolders?.removeAll()
        try await user.update(on: req.db)
        
        let userID = try user.requireID()
        try await Process
            .query(on: req.db)
            .filter(\.$user.$id == userID)
            .delete(force: true)
        
        return .noContent
    }
}
