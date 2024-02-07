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
        // Create
        // Read
        modules.get(use: getAll)
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = modules.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenAuthGroup.post(use: create)
    }
    
    // MARK: - Create
    func create(req: Request) throws -> EventLoopFuture<Module> {
        let module = try req.content.decode(Module.self)
        let user = try req.auth.require(User.self)
        
        guard user.id != nil else {
            throw Abort(.unauthorized, reason: "User not authenticated")
        }

        return module
            .save(on: req.db)
            .map { module }
    }
    
    // MARK: - Read
    func getAll(req: Request) throws -> EventLoopFuture<[Module]> {
        Module
            .query(on: req.db)
            .all()
    }
    
    // MARK: - Update
    // MARK: - Delete
}
