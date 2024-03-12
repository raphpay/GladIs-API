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
        // Basic Auth
        let basicAuthMiddleware = User.authenticator()
        let basicAuthGroup = tokens.grouped(basicAuthMiddleware)
        // Login
        basicAuthGroup.post("login", use: login)
        // Bearer authentication
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = tokens.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenAuthGroup.get(use: getTokens)
        tokenAuthGroup.delete(":tokenID", use: logout)
        tokenAuthGroup.delete("all", use: removeAll)
    }
    
    // MARK: - READ
    func getTokenByID(req: Request) async throws -> Token {
        guard let token = try await Token.find(req.parameters.get("tokenID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        return token
    }
    
    func getTokens(req: Request) async throws -> [Token] {
        try await Token
            .query(on: req.db)
            .all()
    }
    
    // MARK: - Login
    func login(req: Request) async throws -> Token {
        let user = try req.auth.require(User.self)
        let userID = try user.requireID()
        
        // Delete existing tokens
        let token = try await Token
            .query(on: req.db)
            .filter(\.$user.$id == userID)
            .first()
        
        if let token = token {
            token.value = [UInt8].random(count: 16).base64
            try await token.update(on: req.db)
            return token
        } else {
            // If no token exists, create a new one
            let newToken = try! Token.generate(for: user)
            try await newToken.save(on: req.db)
            return newToken
        }
    }
    
    func logout(req: Request) async throws -> HTTPStatus {
        guard let token = try await Token.find(req.parameters.get("tokenID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        try await token.delete(force: true, on: req.db)
        return .noContent
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
