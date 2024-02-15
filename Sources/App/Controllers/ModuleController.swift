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
        // Update
        tokenAuthGroup.put(":moduleID", use: update)
        // Delete
        tokenAuthGroup.delete(":moduleID", use: remove)
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
    func update(req: Request) throws -> EventLoopFuture<Module> {
        let newModule = try req.content.decode(Module.self)
        
        return Module
            .find(req.parameters.get("moduleID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { module in
                module.name = newModule.name
                
                return module
                    .save(on: req.db)
                    .map { module }
            }
    }
    
    // MARK: - Delete
    func remove(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        Module
            .find(req.parameters.get("moduleID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { module in
                module
                    .delete(force: true, on: req.db)
                    .transform(to: .noContent)
            }
    }
}
