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
//        tokenAuthGroup.post(use: create)
        // Read
        tokenAuthGroup.get(use: getAll)
    }
    
    // MARK: - Create
    func create(req: Request) throws -> EventLoopFuture<User.Public> {
        let user = try req.content.decode(User.self)
        
        guard !user.password.isEmpty else {
            throw Abort(.badRequest, reason: "Password cannot be empty")
        }
        
        user.password = try Bcrypt.hash(user.password)

        return user
            .save(on: req.db)
            .map { user.convertToPublic() }
    }
    
    // MARK: - Read
    func getAll(req: Request) throws -> EventLoopFuture<[User.Public]> {
        User
            .query(on: req.db)
            .all()
            .convertToPublic()
    }
    
    // MARK: - Update
    // MARK: - Delete
    // MARK: - Login
    func login(_ req: Request) throws -> EventLoopFuture<Token> {
        let user = try req.auth.require(User.self)
        let token = try Token.generate(for: user)
        return token.save(on: req.db).map { token }
    }
}
