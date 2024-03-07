//
//  AdminUser+Ext.swift
//
//
//  Created by Raphaël Payet on 07/03/2024.
//

import Fluent
import Vapor

extension AdminUser {
    /// Generate a unique username, if user already exists, create a unique username with a suffix
    static func generateUniqueUsername(firstName: String, lastName: String, on req: Request) async throws -> String {
        // Combine first name and last name to generate the initial username
        let initialUsername = "\(firstName.lowercased()).\(lastName.lowercased())"
        
        let admin = try await AdminUser.query(on: req.db)
            .filter(\.$username == initialUsername)
            .first()
        
        guard admin == nil else {
            return try await AdminUser.generateUniqueUsernameWithSuffix(initialUsername: initialUsername, suffix: 1, on: req)
        }
        
        return initialUsername
    }
    
    /// Generate a unique username with a suffix
    private static func generateUniqueUsernameWithSuffix(initialUsername: String, suffix: Int, on req: Request) async throws -> String {
        let uniqueUsername = "\(initialUsername)-\(suffix)"
        
        let admin = try await AdminUser.query(on: req.db)
            .filter(\.$username == initialUsername)
            .first()
        
        guard admin == nil else {
            return try await AdminUser.generateUniqueUsernameWithSuffix(initialUsername: initialUsername, suffix: suffix + 1, on: req)
        }
        
        return uniqueUsername
    }
}

extension AdminUser {
    static func verifyUniqueEmail(_ email: String, on req: Request) async throws -> String {
        let admin = try await AdminUser.query(on: req.db)
            .filter(\.$email == email)
            .first()
        
        guard admin == nil else {
            throw Abort(.badRequest, reason: "Email already in use")
        }
        
        return email
    }
}
