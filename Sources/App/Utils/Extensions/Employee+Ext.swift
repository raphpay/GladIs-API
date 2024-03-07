//
//  File.swift
//  
//
//  Created by Raphaël Payet on 07/03/2024.
//

import Fluent
import Vapor

extension Employee {
    static func generateUniqueUsername(firstName: String, lastName: String, req: Request) async throws -> String {
        let initialUsername = "\(firstName.lowercased()).\(lastName.lowercased())"
        
        let employee = try await Employee.query(on: req.db)
            .filter(\.$username == initialUsername)
            .first()
        
        if employee == nil {
            return initialUsername
        } else {
            return try await generateUniqueUsernameWithSuffix(initialUsername: initialUsername, suffix: 1, req: req)
        }
    }
    
    private static func generateUniqueUsernameWithSuffix(initialUsername: String, suffix: Int, req: Request) async throws -> String {
        let uniqueUsername = "\(initialUsername)-\(suffix)"
        
        let employee = try await Employee.query(on: req.db)
            .filter(\.$username == uniqueUsername)
            .first()
        
        if employee == nil {
            return uniqueUsername
        } else {
            return try await generateUniqueUsernameWithSuffix(initialUsername: initialUsername, suffix: suffix + 1, req: req)
        }
    }
}
