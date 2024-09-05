//
//  FolderController.swift
//
//
//  Created by Raphaël Payet on 06/08/2024.
//

import Fluent
import Vapor

struct FolderController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let processes = routes.grouped("api", "folders")
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
        tokenAuthGroup.put(":folderID", use: update)
        // Delete
        tokenAuthGroup.delete(":folderID", use: delete)
        tokenAuthGroup.delete("all", "for", ":userID", use: deleteAllForUser)
        tokenAuthGroup.delete("all", use: deleteAll)
    }
    
    // MARK: - Create
    func create(req: Request) async throws -> Folder {
        let input = try req.content.decode(Folder.Input.self)
        let user = try await UserController().getUser(with: input.userID, on: req.db)
        let process = try await create(input, for: user, on: req)
        return process
    }
    
    func createMultiple(req: Request) async throws -> [Folder] {
        let input = try req.content.decode(Folder.MultipleInput.self)
        let user = try await UserController().getUser(with: input.userID, on: req.db)
        var createdFolder: [Folder] = []
        for inputProcess in input.inputs {
            let process = try await create(inputProcess, for: user, on: req)
            createdFolder.append(process)
        }
        
        return createdFolder
    }
    
    // MARK: - READ
    @Sendable
    func getAll(req: Request) async throws -> [Folder] {
        try await Folder.query(on: req.db).all()
    }
    
    // MARK: - Update
    @Sendable
    func update(req: Request) async throws -> Folder {
        let folderID = try getID(on: req)
        let folder = try await get(with: folderID, on: req)
        
        let input = try req.content.decode(Folder.UpdateInput.self)
        let updatedFolder = try await input.update(folder, on: req)
        
        let user = try await UserController().getUser(with: updatedFolder.$user.id, on: req.db)
        
        if updatedFolder.sleeve == .systemQuality {
            try await UserController().updateUserSystemQualityFolder(user: user, folder: updatedFolder, on: req)
        } else if updatedFolder.sleeve == .record {
            try await UserController().updateUserRecordsFolder(user: user, folder: updatedFolder, on: req)
        }
        
        return updatedFolder
    }
    
    // MARK: - DELETE
    @Sendable
    func deleteAllForUser(req: Request) async throws -> HTTPResponseStatus {
        let userID = try await UserController().getUserID(on: req)
        let user = try await UserController().getUser(with: userID, on: req.db)
        
        user.recordsFolders?.removeAll()
        user.systemQualityFolders?.removeAll()
        try await user.update(on: req.db)
        
        try await Folder
            .query(on: req.db)
            .filter(\.$user.$id == userID)
            .delete(force: true)
        
        return .noContent
    }
    
    @Sendable
    func delete(req: Request) async throws -> HTTPResponseStatus {
        let folderID = try getID(on: req)
        let folder = try await get(with: folderID, on: req)
        
        try await folder.delete(force: true, on: req.db)
        
        let user = try await UserController().getUser(with: folder.$user.id, on: req.db)
        
        // Remove the Folder from the User's systemQualityFolders and recordsFolders
        if folder.sleeve == .systemQuality {
            try await UserController().removeSystemQualityFolder(user: user, folderID: folderID, on: req)
        } else if folder.sleeve == .record {
            try await UserController().removeRecordFolder(user: user, folderID: folderID, on: req)
        }
        
        return .noContent
    }
    
    @Sendable
    func deleteAll(req: Request) async throws -> HTTPResponseStatus {
        try await Folder
            .query(on: req.db)
            .all()
            .delete(force: true, on: req.db)
        return .noContent
    }
}

// MARK: - Utils
extension FolderController {
    // CREATE
    func create(_ input: Folder.Input, for user: User, on req: Request) async throws -> Folder {
        let process = input.toModel()
        
        try await checkFolderNumberAvailability(process, for: user, on: req)
        
        try await process.save(on: req.db)
        
        if process.sleeve == .systemQuality {
            if var systemQualityFolders = user.systemQualityFolders {
                systemQualityFolders.append(process)
                user.systemQualityFolders = systemQualityFolders
            } else {
                user.systemQualityFolders = [process]
            }
            try await user.update(on: req.db)
        } else if process.sleeve == .record {
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
    
    // GET
    func getID(on req: Request) throws -> Folder.IDValue {
        guard let folderID = req.parameters.get("folderID", as: Folder.IDValue.self) else {
            throw Abort(.badRequest, reason: "badRequest.missingOrIncorrectFolderID")
        }
        
        return folderID
    }
    
    func get(with id: Folder.IDValue, on req: Request) async throws -> Folder {
        guard let folder = try await Folder.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "notFound.folder")
        }
        
        return folder
    }
    
    // PRIVATE
    private func checkFolderNumberAvailability(_ process: Folder, for user: User, on req: Request) async throws {
        let existingProcess = try await Folder.query(on: req.db)
            .filter(\.$user.$id == user.id!)
            .filter(\.$sleeve == process.sleeve)
            .filter(\.$number == process.number)
            .first()
        
        if existingProcess != nil {
            if let maxNumberProcess = try await Folder.query(on: req.db)
                .filter(\.$user.$id == user.id!)
                .filter(\.$sleeve == process.sleeve)
                .sort(\.$number, .descending)
                .first() {
                
                process.number = maxNumberProcess.number + 1
            } else {
                process.number = 1
            }
        }
    }
}
