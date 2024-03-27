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
        passwordResetTokens.get(use: getAll)
        // Delete
        passwordResetTokens.delete(use: removeAll)
    }
    
    // MARK: - Create
    func requestPasswordReset(req: Request) async throws -> HTTPResponseStatus {
        let input = try req.content.decode(User.EmailInput.self)
    
        guard let user = try await User.query(on: req.db)
            .filter(\.$email == input.email)
            .first() else {
            throw Abort(.notFound, reason: "User not found")
        }
        
        let token = PasswordResetToken.generate()
        let userID = try user.requireID()
        let resetToken = PasswordResetToken(token: token, userId: userID, expiresAt: Date().addingTimeInterval(3600))
        
        try await resetToken.save(on: req.db)
        
        return .ok
    }
    
    func resetPassword(req: Request) async throws -> HTTPStatus {
        let input = try req.content.decode(ResetPasswordRequest.self)
        
        guard let token = try await PasswordResetToken.query(on: req.db)
            .filter(\.$token == input.token)
            .first() else {
            throw Abort(.notFound)
        }
        
        guard token.expiresAt > Date() else {
            throw Abort(.badRequest, reason: "Token expired")
        }
        
        guard let user = try await User.find(token.$user.id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        do {
            try PasswordValidation().validatePassword(input.newPassword)
        } catch {
            throw error
        }
        
        // Hash the new password
        let hashedNewPassword = try Bcrypt.hash(input.newPassword)
        
        guard token.expiresAt > Date() else {
            throw Abort(.badRequest, reason: "Token expired")
        }
        
        guard let user = try await User.find(token.$user.id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        user.password = hashedNewPassword
        try await user.save(on: req.db)
        
        try await token.delete(force: true, on: req.db)
        
        return .ok
    }
    
    // MARK: - Read
    func getAll(req: Request) async throws -> [PasswordResetToken] {
        try await PasswordResetToken.query(on: req.db).all()
    }
    
    // MARK: - Delete
    func removeAll(req: Request) async throws -> HTTPResponseStatus {
        let tokens = try await PasswordResetToken.query(on: req.db).all()
        
        for token in tokens {
            do {
                try await token.delete(force: true, on: req.db)
            } catch let error {
                throw Abort(.badRequest, reason: error.localizedDescription)
            }
        }
        
        return .noContent
    }
}

