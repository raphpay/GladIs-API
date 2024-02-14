//
//  User+Ext.swift
//
//
//  Created by Raphaël Payet on 12/02/2024.
//

import Fluent
import Vapor

extension User {
    static func generateUniqueUsername(firstName: String, lastName: String, on req: Request) -> EventLoopFuture<String> {
        // Combine first name and last name to generate the initial username
        let initialUsername = "\(firstName.lowercased()).\(lastName.lowercased())"
        
        // Check if the initial username is unique
        return User.query(on: req.db)
            .filter(\.$username == initialUsername)
            .first()
            .flatMap { existingUser in
                // If no user with the initial username exists, return it
                guard existingUser == nil else {
                    // If the initial username is not unique, generate a unique username with a suffix
                    return User.generateUniqueUsernameWithSuffix(initialUsername: initialUsername, suffix: 1, on: req)
                }
                return req.eventLoop.future(initialUsername)
            }
    }
    
    // Generate a unique username with a suffix
    private static func generateUniqueUsernameWithSuffix(initialUsername: String, suffix: Int, on req: Request) -> EventLoopFuture<String> {
        let uniqueUsername = "\(initialUsername)-\(suffix)"
        
        // Check if the unique username is already taken
        return User.query(on: req.db)
            .filter(\.$username == uniqueUsername)
            .first()
            .flatMap { existingUser in
                // If the unique username is not taken, return it
                guard existingUser == nil else {
                    // If the unique username is still not unique, recursively generate a new one with an incremented suffix
                    return User.generateUniqueUsernameWithSuffix(initialUsername: initialUsername, suffix: suffix + 1, on: req)
                }
                return req.eventLoop.future(uniqueUsername)
            }
    }
}