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
        tokenAuthGroup.post("multiple", use: createMultiple)
        // Read
        tokenAuthGroup.get(use: getAll)
        // Update
        tokenAuthGroup.put(":processusID", use: update)
        // Delete
        tokenAuthGroup.delete(":processusID", use: delete)
        tokenAuthGroup.delete("all", "for", ":userID", use: deleteAllForUser)
    }
    
    // MARK: - Create
    func create(req: Request) async throws -> Processus {
        let input = try req.content.decode(Processus.Input.self)
        let user = try await UserController().getUser(with: input.userID, on: req.db)
        let process = try await create(input, for: user, on: req)
        return process
    }
    
    func createMultiple(req: Request) async throws -> [Processus] {
        let input = try req.content.decode(Processus.MultipleInput.self)
        let user = try await UserController().getUser(with: input.userID, on: req.db)
        var createdProcessus: [Processus] = []
        for inputProcess in input.inputs {
            let process = try await create(inputProcess, for: user, on: req)
            createdProcessus.append(process)
        }
        
        return createdProcessus
    }
    
    // MARK: - READ
    @Sendable
    func getAll(req: Request) async throws -> [Processus] {
        try await Processus.query(on: req.db).all()
    }
    
    // MARK: - Update
    @Sendable
    func update(req: Request) async throws -> Processus {
        let processusID = try getID(on: req)
        let processus = try await get(with: processusID, on: req)
        
        let input = try req.content.decode(Processus.UpdateInput.self)
        let updatedProcessus = try await input.update(processus, on: req)
        
        let user = try await UserController().getUser(with: updatedProcessus.$user.id, on: req.db)
        
        if updatedProcessus.folder == .systemQuality {
            try await UserController().updateUserSystemQualityFolder(user: user, processus: updatedProcessus, on: req)
        } else if updatedProcessus.folder == .record {
            try await UserController().updateUserRecordsFolder(user: user, processus: updatedProcessus, on: req)
        }
        
        return updatedProcessus
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
    
    @Sendable
    func delete(req: Request) async throws -> HTTPResponseStatus {
        let processusID = try getID(on: req)
        let processus = try await get(with: processusID, on: req)
        
        try await processus.delete(force: true, on: req.db)
        
        let user = try await UserController().getUser(with: processus.$user.id, on: req.db)
        
        // Remove the Processus from the User's systemQualityFolders and recordsFolders
        if processus.folder == .systemQuality {
            try await UserController().removeSystemQualityProcessus(user: user, processusID: processusID, on: req)
        } else if processus.folder == .record {
            try await UserController().removeRecordProcessus(user: user, processusID: processusID, on: req)
        }
        
        return .noContent
    }
}

// MARK: - Utils
extension ProcessusController {
    func getID(on req: Request) throws -> Processus.IDValue {
        guard let processusID = req.parameters.get("processusID", as: Processus.IDValue.self) else {
            throw Abort(.badRequest, reason: "badRequest.missingOrIncorrectProcessusID")
        }
        
        return processusID
    }
    
    func get(with id: Processus.IDValue, on req: Request) async throws -> Processus {
        guard let processus = try await Processus.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "notFound.processus")
        }
        
        return processus
    }
    
    func create(_ input: Processus.Input, for user: User, on req: Request) async throws -> Processus {
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
}
