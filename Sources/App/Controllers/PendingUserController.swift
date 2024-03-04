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
        pendingUsers.post(":pendingUserID", "modules", ":moduleID", use: addModule)
        pendingUsers.get(":pendingUserID", "modules", use: getModules)
        // Token Protected
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = pendingUsers.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        // Post
        tokenAuthGroup.post(":pendingUserID", "convertToUser", use: convertToUser)
        // Read
        tokenAuthGroup.get(use: getAll)
        tokenAuthGroup.get(":pendingUserID", use: getAll)
        // Update
        tokenAuthGroup.put(":pendingUserID", "status", use: updateStatus)
        // Delete
        tokenAuthGroup.delete(":pendingUserID", use: remove)
    }
    
    // MARK: - CREATE
    func create(req: Request) throws -> EventLoopFuture<PendingUser> {
        try PendingUser.validate(content: req)
        let user = try req.content.decode(PendingUser.self)
        
        return user
            .save(on: req.db)
            .map { user }
    }
    
    func addModule(req: Request) throws -> EventLoopFuture<Module> {
        let pendingUserQuery = PendingUser
            .find(req.parameters.get("pendingUserID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        let moduleQuery = Module
            .find(req.parameters.get("moduleID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        return pendingUserQuery.and(moduleQuery)
            .flatMap { user, module in
                user
                    .$modules
                    .attach(module, on: req.db)
                    .map { module }
            }
    }
    
    func convertToUser(req: Request) throws -> EventLoopFuture<User.Public> {
        let user = try req.auth.require(User.self)
        
        guard user.userType == .admin else {
            throw Abort(.badRequest, reason: "User should be admin to create a user from pending user")
        }
        
        return PendingUser
            .find(req.parameters.get("pendingUserID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { pendingUser in
                let user = pendingUser.convertToUser()
                return User
                    .generateUniqueUsername(firstName: user.firstName, lastName: user.lastName, on: req)
                    .flatMap { username in
                        user.username = username
                        return user.save(on: req.db)
                            .map { user.convertToPublic() }
                    }
            }
    }
    
    // MARK: - READ
    func getAll(req: Request) throws -> EventLoopFuture<[PendingUser]> {
        let authUser = try req.auth.require(User.self)
        
        guard authUser.userType == .admin else {
            throw Abort(.badRequest, reason: "User should be admin for this action")
        }
        
        return PendingUser
            .query(on: req.db)
            .all()
    }
    
    func getModules(req: Request) throws -> EventLoopFuture<[Module]> {
        PendingUser
            .find(req.parameters.get("pendingUserID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user
                    .$modules
                    .query(on: req.db)
                    .all()
            }
    }
    
    // MARK: - UPDATE
    func updateStatus(req: Request) throws -> EventLoopFuture<PendingUser> {
        let user = try req.auth.require(User.self)
        
        guard user.userType == .admin else {
            throw Abort(.badRequest, reason: "User should be admin to complete this action")
        }
        
        let newStatus = try req.content.decode(PendingUser.Status.self)
        return PendingUser.find(req.parameters.get("pendingUserID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { pendingUser in
                pendingUser.status = newStatus.type
                return pendingUser
                    .save(on: req.db)
                    .map { pendingUser }
        }
    }
    
    // MARK: - DELETE
    func remove(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let user = try req.auth.require(User.self)
        
        guard user.userType == .admin else {
            throw Abort(.badRequest, reason: "User should be admin to create a user from pending user")
        }
        
        return PendingUser
            .find(req.parameters.get("pendingUserID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { pendingUser in
                return pendingUser
                    .delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
}
