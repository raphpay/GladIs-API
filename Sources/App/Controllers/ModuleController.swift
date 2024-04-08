//
//  ModuleController.swift
//
//
//  Created by Raphaël Payet on 07/02/2024.
//


import Fluent
import Vapor

struct ModuleController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let modules = routes.grouped("api", "modules")
        // Read
        modules.get(use: getAll)
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = modules.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        // Create
        tokenAuthGroup.post(use: create)
        // Read
        tokenAuthGroup.get("sorted", use: getSorted)
        // Update
        tokenAuthGroup.put(":moduleID", use: update)
        // Delete
        tokenAuthGroup.delete(":moduleID", use: remove)
    }
    
    // MARK: - Create
    func create(req: Request) async throws -> Module {
        let input = try req.content.decode(Module.Input.self)
        let user = try req.auth.require(User.self)
        
        guard user.id != nil,
              user.userType == .admin else {
            throw Abort(.unauthorized, reason: "User not authenticated")
        }
        
        let module = Module(name: input.name, index: input.index)
        let moduleQuery = try await Module.query(on: req.db).filter(\.$index == input.index).first()
        
        if moduleQuery != nil {
            throw Abort(.badRequest, reason: "Module with index \(input.index) already exists")
        }
        
        try await module.save(on: req.db)
        return module
    }

    
    // MARK: - Read
    func getAll(req: Request) async throws -> [Module]{
        try await Module
            .query(on: req.db)
            .all()
    }
    
    func getSorted(req: Request) async throws -> [Module] {
        try await Module
            .query(on: req.db)
            .sort(\.$index)
            .all()
    }

    // Update index
    // MARK: - Update
    func update(req: Request) async throws -> Module {
        let newModule = try req.content.decode(Module.Input.self)
        
        guard let module = try await Module.find(req.parameters.get("moduleID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.module")
        }
        module.name = newModule.name
        module.index = newModule.index
        try await module.save(on: req.db)
        
        let moduleToReturn = Module(id: module.id, name: newModule.name, index: newModule.index)
        
        return moduleToReturn
    }

    
    // MARK: - Delete
    func remove(req: Request) async throws -> HTTPStatus {
        guard let module = try await Module.find(req.parameters.get("moduleID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.module")
        }
        
        try await module.delete(force: true, on: req.db)
        return .noContent
    }
}
