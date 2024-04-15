//
//  PasswordResetTokenController.swift
//
//
//  Created by Raphaël Payet on 27/03/2024.
//


import Fluent
import Vapor

struct PasswordResetTokenController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let passwordResetTokens = routes.grouped("api", "passwordResetTokens")
        // Create
        passwordResetTokens.post("request", use: requestPasswordReset)
        passwordResetTokens.post("reset", use: resetPassword)
        // Read
        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = passwordResetTokens.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenAuthGroup.get(use: getAll)
        // Delete
        tokenAuthGroup.delete(":passwordResetTokenID", use: remove)
        tokenAuthGroup.delete(use: removeAll)
    }
    
    // MARK: - Create
    func requestPasswordReset(req: Request) async throws -> HTTPResponseStatus {
        let input = try req.content.decode(User.EmailInput.self)
    
        guard let user = try await User.query(on: req.db)
            .filter(\.$email == input.email)
            .first() else {
            throw Abort(.notFound, reason: "notFound.user")
        }
        
        let userID = try user.requireID()
        
        let token = try await PasswordResetToken
            .query(on: req.db)
            .filter(\.$user.$id == userID)
            .first()
        
        if let existingToken = token {
            existingToken.token = PasswordResetToken.generate()
            existingToken.expiresAt = Date().addingTimeInterval(3600)
            try await existingToken.update(on: req.db)
        } else {
            let token = PasswordResetToken.generate()
            let resetToken = PasswordResetToken(token: token, 
                                                userId: userID,
                                                userEmail: input.email,
                                                expiresAt: Date().addingTimeInterval(3600))
            try await resetToken.save(on: req.db)
        }
        
        return .ok
    }
    
    func resetPassword(req: Request) async throws -> HTTPStatus {
        let input = try req.content.decode(ResetPasswordRequest.self)
        
        guard let token = try await PasswordResetToken.query(on: req.db)
            .filter(\.$token == input.token)
            .first() else {
            throw Abort(.notFound, reason: "notFound.resetToken")
        }
        
        guard token.expiresAt > Date() else {
            throw Abort(.badRequest, reason: "badRequest.tokenExpired")
        }
        
        do {
            try PasswordValidation().validatePassword(input.newPassword)
        } catch {
            throw error
        }
        
        // Hash the new password
        let hashedNewPassword = try Bcrypt.hash(input.newPassword)
        
        guard let user = try await User.find(token.$user.id, on: req.db) else {
            throw Abort(.notFound, reason: "notFound.user")
        }
        
        user.password = hashedNewPassword
        user.firstConnection = false
        try await user.save(on: req.db)
        
        try await token.delete(force: true, on: req.db)
        
        return .ok
    }
    
    // MARK: - Read
    func getAll(req: Request) async throws -> [PasswordResetToken.Public] {
        try await PasswordResetToken.query(on: req.db).all().convertToPublic()
    }
    
    // MARK: - Delete
    func remove(req: Request) async throws -> HTTPResponseStatus {
        guard let token = try await PasswordResetToken.find(req.parameters.get("passwordResetTokenID"), on: req.db) else {
            throw Abort(.notFound, reason: "notFound.passwordResetToken")
        }
        
        try await token.delete(force: true, on: req.db)
        
        return .noContent
    }
    
    func removeAll(req: Request) async throws -> HTTPResponseStatus {
        let tokens = try await PasswordResetToken.query(on: req.db).all()
        
        for token in tokens {
            do {
                try await token.delete(force: true, on: req.db)
            } catch let error {
                throw Abort(.badRequest, reason: "badRequest.passwordResetToken.delete")
            }
        }
        
        return .noContent
    }
}

