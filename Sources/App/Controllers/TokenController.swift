//
//  TokenController.swift
//
//
//  Created by Raphaël Payet on 09/02/2024.
//


import Fluent
import Vapor

struct TokenController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let tokens = routes.grouped("api", "tokens")
        tokens.get(":tokenID", use: getTokenByID)
        tokens.get(use: getTokens)
        tokens.delete(":tokenID", use: logout)
        // Basic Auth
        let basicAuthMiddleware = User.authenticator()
        let basicAuthGroup = tokens.grouped(basicAuthMiddleware)
        // Login
        basicAuthGroup.post("login", use: login)
        // Bearer authentication
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = tokens.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenAuthGroup.delete("all", use: removeAll)
    }
    
    // MARK: - READ
    func getTokenByID(req: Request) throws -> EventLoopFuture<Token> {
        Token
            .find(req.parameters.get("tokenID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func getTokens(req: Request) throws -> EventLoopFuture<[Token]> {
        Token
            .query(on: req.db)
            .all()
    }
    
    // MARK: - Login
    func login(req: Request) throws -> EventLoopFuture<Token> {
        let user = try req.auth.require(User.self)
        let userID = try user.requireID()
        
        // Delete existing tokens
        return Token
            .query(on: req.db)
            .filter(\.$user.$id == userID)
            .first()
            .flatMap { token in
                if let token = token {
                    // If a token exists, update its value
                    token.value = [UInt8].random(count: 16).base64
                    return token
                        .update(on: req.db)
                        .transform(to: token)
                } else {
                    // If no token exists, create a new one
                    let newToken = try! Token.generate(for: user)
                    return newToken
                        .save(on: req.db)
                        .map { newToken }
                }
            }
    }
    
    func logout(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        Token
            .find(req.parameters.get("tokenID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { token in
                token
                    .delete(force: true, on: req.db)
                    .transform(to: .noContent)
            }
    }
    
    // MARK: - Delete
    func removeAll(req: Request) async throws -> HTTPResponseStatus {
        let authUser = try req.auth.require(User.self)
        
        guard authUser.userType == .admin else {
            throw Abort(.badRequest, reason: "User should be admin to delete tokens")
        }
        
        try await Token.query(on: req.db)
            .all()
            .delete(force: true, on: req.db)
        
        return .noContent
    }
}
