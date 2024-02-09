//
//  UserController.swift
//  
//
//  Created by Raphaël Payet on 07/02/2024.
//


import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let users = routes.grouped("api", "users")
        users.post(use: create)
        // Basic Auth
        let basicAuthMiddleware = User.authenticator()
        let basicAuthGroup = users.grouped(basicAuthMiddleware)
        // Login
        basicAuthGroup.post("login", use: login)
        // Token Protected
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = users.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        // Create
        tokenAuthGroup.post(":userID", "modules", ":moduleID", use: addModule)
        // Read
        tokenAuthGroup.get(use: getAll)
        tokenAuthGroup.get(":userID", use: getUser)
        tokenAuthGroup.get(":userID", "modules", use: getModules)
        // Update
        tokenAuthGroup.put(":userID", "setFirstConnectionToFalse", use: setUserFirstConnectionToFalse)
        tokenAuthGroup.put(":userID", "changePassword", use: changePassword)
    }
    
    // MARK: - Create
    func create(req: Request) throws -> EventLoopFuture<User.Public> {
        let user = try req.content.decode(User.self)
        
        guard !user.password.isEmpty else {
            throw Abort(.badRequest, reason: "Password cannot be empty")
        }
        
        guard user.userType == .admin else {
            throw Abort(.badRequest, reason: "User should be admin to create another user")
        }
        
        user.password = try Bcrypt.hash(user.password)

        return user
            .save(on: req.db)
            .map { user.convertToPublic() }
    }
    
    func addModule(req: Request) throws -> EventLoopFuture<Module> {
        let userQuery = User
            .find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        let moduleQuery = Module
            .find(req.parameters.get("moduleID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        return userQuery.and(moduleQuery)
            .flatMap { user, module in
                user
                    .$modules
                    .attach(module, on: req.db)
                    .map { module }
            }
    }
    
    // MARK: - Read
    func getAll(req: Request) throws -> EventLoopFuture<[User.Public]> {
        User
            .query(on: req.db)
            .all()
            .convertToPublic()
    }
    
    func getUser(req: Request) throws -> EventLoopFuture<User.Public> {
        User
            .find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .map { user in
                return user.convertToPublic()
            }
    }
    
    func getModules(req: Request) throws -> EventLoopFuture<[Module]> {
        User
            .find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user
                    .$modules
                    .query(on: req.db)
                    .all()
            }
    }
    
    // MARK: - Update
    func setUserFirstConnectionToFalse(req: Request) throws -> EventLoopFuture<User.Public> {
        User
            .find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.firstConnection = false
                return user
                    .save(on: req.db)
                    .map { user.convertToPublic() }
            }
    }
    
    func changePassword(req: Request) throws -> EventLoopFuture<PasswordChangeResponse> {
        let user = try req.auth.require(User.self)
        let userId = try req.parameters.require("userID", as: UUID.self)
        
        guard user.id == userId else {
            throw Abort(.forbidden, reason: "Unauthorized access")
        }
        
        // Decode the request body containing the new password
        let changeRequest = try req.content.decode(PasswordChangeRequest.self)
        
        // Verify that the current password matches the one stored in the database
        let isCurrentPasswordValid = try Bcrypt.verify(changeRequest.currentPassword, created: user.password)
        // TODO: Add more verification on password
        guard isCurrentPasswordValid else {
            throw Abort(.unauthorized, reason: "Invalid current password")
        }
        
        // Hash the new password
        let hashedNewPassword = try Bcrypt.hash(changeRequest.newPassword)
        
        // Update the user's password in the database
        return User
            .find(userId, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.password = hashedNewPassword
                return user
                    .save(on: req.db)
                    .transform(to: PasswordChangeResponse(message: "Password changed successfully"))
            }
    }
    
    // MARK: - Delete
    // MARK: - Login
    func login(req: Request) throws -> EventLoopFuture<Token> {
        let user = try req.auth.require(User.self)
        let token = try Token.generate(for: user)
        return token.save(on: req.db).map { token }
    }
}
