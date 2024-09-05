//
//  UserController+Ext.swift
//
//
//  Created by Raphaël Payet on 05/09/2024.
//

@testable import App
import XCTVapor
import Fluent

extension User {
    static func create(username: String, userType: User.UserType = .admin, email: String = "test@test.com", password: String = "Passwordtest123(", on database: Database) async throws -> User {
        let hashedPassword = try Bcrypt.hash(password)
        let user = User(firstName: "testFirstName", lastName: "testLastName",
                        phoneNumber: "0601234567", username: username,
                        password: hashedPassword, email: email,
                        firstConnection: true, userType: userType)
        try await user.save(on: database)
        
        return user
    }
    
    static func attachModule(_ module: Module, to user: User, on database: Database) async throws {
        if user.modules == nil {
            user.modules = []
        } else {
            user.modules?.append(module)
        }
        try await user.update(on: database)
    }
    
    static func attachTechnicalTab(_ tab: TechnicalDocumentationTab, to user: User, on database: Database) async throws {
        try await user.$technicalDocumentationTabs.attach(tab, on: database)
    }
    
    static func deleteAll(on database: Database) async throws {
        try await User.query(on: database)
            .withDeleted()
            .all()
            .delete(force: true, on: database)
    }
}

extension UserControllerTests {
    func createExpectedAdmin(on db: Database) async throws -> User {
        let hashedPassword = try Bcrypt.hash("Passwordtest123")
        let user = User(firstName: expectedFirstName,
                        lastName: expectedLastName,
                        phoneNumber: expectedPhoneNumber,
                        username: expectedUsername,
                        password: hashedPassword,
                        email: expectedEmail,
                        firstConnection: true,
                        userType: .admin)
        
        try await user.save(on: db)
        
        return user
    }
}
