//
//  EventControllerTests+Utils.swift
//  
//
//  Created by Raphaël Payet on 15/04/2024.
//

@testable import App
import XCTVapor

extension EventControllerTests {
    func createUser(userType: User.UserType = .admin) async throws -> User {
        let user = User(firstName: "testFirstName", lastName: "testLastName",
                        phoneNumber: "0601234567", username: expectedUsername,
                        password: "PasswordTest15", email: "test@test.com",
                        firstConnection: true, userType: userType)
        try await user.save(on: app.db)
        
        return user
    }
    
    func createToken(user: User) async throws -> Token {
        let token = try Token.generate(for: user)
        try await token.save(on: app.db)
        return token
    }
    
    func createEvent(name: String? = nil, clientID: UUID = UUID()) async throws -> Event{
        let event = Event(name: name ?? expectedEventName, date: Date.now.timeIntervalSince1970, clientID: clientID)
        try await event.save(on: app.db)
        return event
    }
}
