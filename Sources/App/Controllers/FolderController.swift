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
        let folders = routes.grouped("api", "folders")
        // Token Protected
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = folders.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        // Create
        tokenAuthGroup.post(use: create)
        tokenAuthGroup.post("multiple", use: createMultiple)
        // Read
        tokenAuthGroup.get(use: getAll)
        // Update
        tokenAuthGroup.put(":folderID", use: update)
        // Delete
        tokenAuthGroup.delete(":folderID", use: delete)
        tokenAuthGroup.delete("all", use: deleteAll)
    }
    
    // MARK: - Create
    func create(req: Request) async throws -> Folder {
        let input = try req.content.decode(Folder.Input.self)
        let user = try await UserController().getUser(with: input.userID, on: req.db)
        let folder = try await create(input, for: user, on: req)
        return folder
    }
    
    func createMultiple(req: Request) async throws -> [Folder] {
        let input = try req.content.decode(Folder.MultipleInput.self)
        let user = try await UserController().getUser(with: input.userID, on: req.db)
        var createdFolders: [Folder] = []
        for inputFolder in input.inputs {
            let folder = try await create(inputFolder, for: user, on: req)
            createdFolders.append(folder)
        }
        
        return createdFolders
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
        
        return updatedFolder
    }
    
    // MARK: - DELETE
    @Sendable
    func delete(req: Request) async throws -> HTTPResponseStatus {
        try await checkUserRole(on: req)
        
        let folderID = try getID(on: req)
        let folder = try await get(with: folderID, on: req)
        
        try await folder.delete(force: true, on: req.db)
        
        return .noContent
    }
    
    @Sendable
    func deleteAll(req: Request) async throws -> HTTPResponseStatus {
        try await checkUserRole(on: req)
        
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
        let folder = input.toModel()
        try await checkFolderNumberAvailability(folder, for: user, on: req)
        try await folder.save(on: req.db)
        return folder
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
    private func checkFolderNumberAvailability(_ folder: Folder, for user: User, on req: Request) async throws {
        let existingFolder = try await Folder.query(on: req.db)
            .filter(\.$user.$id == user.id!)
            .filter(\.$sleeve == folder.sleeve)
            .filter(\.$number == folder.number)
            .first()
        
        if existingFolder != nil {
            if let maxNumberFolder = try await Folder.query(on: req.db)
                .filter(\.$user.$id == user.id!)
                .filter(\.$sleeve == folder.sleeve)
                .sort(\.$number, .descending)
                .first() {
                
                folder.number = maxNumberFolder.number + 1
            } else {
                folder.number = 1
            }
        }
    }
    
    private func checkUserRole(on req: Request) async throws {
        let authenticatedUser = try req.auth.require(User.self)
        
        guard authenticatedUser.userType == .admin else {
            throw Abort(.forbidden, reason: "forbidden.userShouldBeAdmin")
        }
    }
}
