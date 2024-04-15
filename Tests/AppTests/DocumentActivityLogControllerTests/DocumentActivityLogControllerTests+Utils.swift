//
//  DocumentActivityLogControllerTests+Utils.swift
//
//
//  Created by Raphaël Payet on 15/04/2024.
//

@testable import App
import XCTVapor
import Fluent

extension DocumentActivityLogControllerTests {
    func createUser(app: Application, username: String) async throws -> User {
        let user = User(firstName: "testFirstName", lastName: "testLastName",
                        phoneNumber: "0601234567", username: username,
                        password: "PasswordTest15", email: "test@test.com",
                        firstConnection: true, userType: .admin)
        try await user.save(on: app.db)
        
        return user
    }
    
    func createToken(app: Application, user: User) async throws -> Token {
        let token = try Token.generate(for: user)
        try await token.save(on: app.db)
        return token
    }
}
