//
//  ProcessusController.swift
//
//
//  Created by Raphaël Payet on 06/08/2024.
//

import Fluent
import Vapor

struct ProcessusController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let processes = routes.grouped("api", "processus")
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
    func create(req: Request) async throws -> Processus {
        let input = try req.content.decode(Processus.Input.self)
        let user = try await UserController().getUser(with: input.userID, on: req.db)
        let process = input.toModel()
        
        try await process.save(on: req.db)
        
        if process.folder == .systemQuality {
            if var systemQualityFolders = user.systemQualityFolders {
                systemQualityFolders.append(process)
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
    func getAll(req: Request) async throws -> [Processus] {
        try await Processus.query(on: req.db).all()
    }
    
    // MARK: - DELETE
    @Sendable
    func deleteAllForUser(req: Request) async throws -> HTTPResponseStatus {
        let userID = try await UserController().getUserID(on: req)
        let user = try await UserController().getUser(with: userID, on: req.db)
        
        user.recordsFolders?.removeAll()
        user.systemQualityFolders?.removeAll()
        try await user.update(on: req.db)
        
        try await Processus
            .query(on: req.db)
            .filter(\.$user.$id == userID)
            .delete(force: true)
        
        return .noContent
    }
}
