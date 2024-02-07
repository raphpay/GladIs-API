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
        modules.post(use: create)
        // Read
        modules.get(use: getAll)
    }
    
    // MARK: - Create
    func create(req: Request) throws -> EventLoopFuture<Module> {
        let module = try req.content.decode(Module.self)

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
