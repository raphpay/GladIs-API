//
//  User+Ext.swift
//
//
//  Created by Raphaël Payet on 12/02/2024.
//

import Fluent
import Vapor

extension User {
    static func generateUniqueUsername(firstName: String, lastName: String, on req: Request) async throws -> String {
        // Combine first name and last name to generate the initial username
        let initialUsername = "\(firstName.lowercased()).\(lastName.lowercased())"
        
        let user = try await User
            .query(on: req.db)
            .filter(\.$username == initialUsername)
            .first()
        
        // If no user with the initial username exists, return it
        guard user == nil else {
            // If the initial username is not unique, generate a unique username with a suffix
            return try await User.generateUniqueUsernameWithSuffix(initialUsername: initialUsername, suffix: 1, on: req)
        }
        return initialUsername
    }
    
    // Generate a unique username with a suffix
    private static func generateUniqueUsernameWithSuffix(initialUsername: String, suffix: Int, on req: Request) async throws -> String {
        let uniqueUsername = "\(initialUsername)-\(suffix)"
        
        let user = try await User.query(on: req.db)
            .filter(\.$username == uniqueUsername)
            .first()
        
        // If the unique username is not taken, return it
        guard user == nil else {
            // If the unique username is still not unique, recursively generate a new one with an incremented suffix
            return try await User.generateUniqueUsernameWithSuffix(initialUsername: initialUsername, suffix: suffix + 1, on: req)
        }
        return uniqueUsername
    }
}

extension User {
    static func verifyUniqueEmail(_ email: String, on req: Request) async throws -> String {
        let user = try await User.query(on: req.db)
            .filter(\.$email == email)
            .first()
        
        guard user == nil else {
            // If a user with the email already exists, throw an error
            throw Abort(.badRequest, reason: "badRequest.emailAlreadyExists")
        }
        // If the email is unique, return it
        return email
    }
}

extension EventLoopFuture where Value: User {
    func convertToPublic() -> EventLoopFuture<User.Public> {
        return self.map { user in
            return user.convertToPublic()
        }
    }
}


extension Collection where Element: User {
    func convertToPublic() -> [User.Public] {
        return self.map { $0.convertToPublic() }
    }
}

extension EventLoopFuture where Value == Array<User> {
    func convertToPublic() -> EventLoopFuture<[User.Public]> {
        return self.map { $0.convertToPublic() }
    }
}

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$username
    static let passwordHashKey = \User.$password
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}
