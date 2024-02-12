//
//  PendingUserController.swift
//
//
//  Created by Raphaël Payet on 12/02/2024.
//

import Fluent
import Vapor

struct PendingUserController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let pendingUsers = routes.grouped("api", "pendingUsers")
        pendingUsers.post(use: create)
//        // Token Protected
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = pendingUsers.grouped(tokenAuthMiddleware, guardAuthMiddleware)
//        // Read
        tokenAuthGroup.get(use: getAll)
        tokenAuthGroup.get(":pendingUserID", use: getAll)
        // Update
        tokenAuthGroup.put(":pendingUserID", "status", use: updateStatus)
        // Delete
        tokenAuthGroup.delete(":pendingUserID", use: remove)
    }
    
    // MARK: - CREATE
    func create(req: Request) throws -> EventLoopFuture<PendingUser> {
        let user = try req.content.decode(PendingUser.self)
        
        return user
            .save(on: req.db)
            .map { user }
    }
    
    // MARK: - READ
    func getAll(req: Request) throws -> EventLoopFuture<[PendingUser]> {
        PendingUser
            .query(on: req.db)
            .all()
    }
    
    func getByID(req: Request) throws -> EventLoopFuture<PendingUser> {
        PendingUser
            .find(req.parameters.get("pendingUserID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .map { pendingUser in
                return pendingUser
            }
    }
    
    // MARK: - UPDATE
    func updateStatus(req: Request) throws -> EventLoopFuture<PendingUser> {
        let newStatus = try req.content.decode(PendingUser.Status.self)
        return PendingUser.find(req.parameters.get("pendingUserID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { pendingUser in
                pendingUser.status = newStatus
                return pendingUser
                    .save(on: req.db)
                    .map { pendingUser }
        }
    }
    
    // MARK: - DELETE
    func remove(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        PendingUser
            .find(req.parameters.get("pendingUserID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { pendingUser in
                return pendingUser
                    .delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
}
