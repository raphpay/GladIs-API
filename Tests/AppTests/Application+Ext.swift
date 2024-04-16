//
//  File.swift
//  
//
//  Created by Raphaël Payet on 16/04/2024.
//

@testable import App
import XCTVapor
import Fluent


extension User {
    static func create(username: String, userType: User.UserType = .admin, on database: Database) async throws -> User {
        let user = User(firstName: "testFirstName", lastName: "testLastName",
                        phoneNumber: "0601234567", username: username,
                        password: "PasswordTest15", email: "test@test.com",
                        firstConnection: true, userType: userType)
        try await user.save(on: database)
        
        return user
    }
}

extension Token {
    static func create(for user: User, on database: Database) async throws -> Token {
        let token = try Token.generate(for: user)
        try await token.save(on: database)
        return token
    }
}

extension Document {
    static func create(name: String, path: String, status: Document.Status = .none, on database: Database) async throws -> Document {
        let document = Document(name: name, path: path, status: status)
        try await document.save(on: database)
        return document
    }
}

extension Event {
    static func create(name: String, clientID: UUID = UUID(), on database: Database) async throws -> Event{
        let event = Event(name: name, date: Date.now.timeIntervalSince1970, clientID: clientID)
        try await event.save(on: database)
        return event
    }
    
    static func archive(_ event: Event, on database: Database) async throws {
        try await event.delete(force: false, on: database)
    }
    
    static func deleteAll(on database: Database) async throws {
        try await Event.query(on: database)
            .withDeleted()
            .all()
            .delete(force: true, on: database)
    }
    
    static func get(_ id: UUID, on database: Database) async throws -> Event? {
        let events = try await Event.query(on: database)
            .withDeleted()
            .all()
        
        let filteredEvents = events.filter{ $0.id == id }
        return filteredEvents.first
    }
}
