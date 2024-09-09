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
    
    // TODO: Check if still needed
    static func attachModule(_ module: Module, to user: User, on database: Database) async throws {
        if user.modules == nil {
            user.modules = []
        } else {
            user.modules?.append(module)
        }
        try await user.update(on: database)
    }
    
    func attachModules(_ modules: [Module], on db: Database) async throws {
        self.modules = modules
        try await self.update(on: db)
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
        let user = User(firstName: expectedAdminFirstName,
                        lastName: expectedAdminLastName,
                        phoneNumber: expectedAdminPhoneNumber,
                        username: expectedAdminUsername,
                        password: hashedPassword,
                        email: expectedAdminEmail,
                        firstConnection: true,
                        userType: .admin)
        
        try await user.save(on: db)
        
        return user
    }
    
    func createExpectedUser(userType: User.UserType = .client, on db: Database) async throws -> User {
        let hashedPassword = try Bcrypt.hash(expectedPassword)
        let user = User(firstName: expectedFirstName,
                        lastName: expectedLastName,
                        phoneNumber: expectedPhoneNumber,
                        username: expectedUsername,
                        password: hashedPassword,
                        email: expectedEmail,
                        firstConnection: true,
                        userType: userType)
        
        try await user.save(on: db)
        
        return user
    }
    
    func createExpectedUserInput(firstName: String? = nil,
                                 lastName: String? = nil,
                                 password: String? = nil) -> User.Input {
        var inputFirstName = firstName
        if inputFirstName == nil { inputFirstName = expectedFirstName }
        
        var inputLastName = lastName
        if inputLastName == nil { inputLastName = expectedLastName }
        
        var inputPassword = password
        if inputPassword == nil { inputPassword = expectedPassword }
        
        let input = User.Input(firstName: inputFirstName!, lastName: inputLastName!,
                                   phoneNumber: expectedPhoneNumber, email: expectedEmail,
                                   password: inputPassword, userType: .admin,
                                   companyName: nil, products: nil,
                                   numberOfEmployees: nil, numberOfUsers: nil,
                                   salesAmount: nil, employeesIDs: nil, managerID: nil)
        
        return input
    }
}
