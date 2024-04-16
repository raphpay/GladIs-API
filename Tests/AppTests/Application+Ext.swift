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
    static func create(username: String, userType: User.UserType = .admin, email: String = "test@test.com", on database: Database) async throws -> User {
        let user = User(firstName: "testFirstName", lastName: "testLastName",
                        phoneNumber: "0601234567", username: username,
                        password: "PasswordTest15", email: email,
                        firstConnection: true, userType: userType)
        try await user.save(on: database)
        
        return user
    }
    
    static func deleteAll(on database: Database) async throws {
        try await User.query(on: database)
            .withDeleted()
            .all()
            .delete(force: true, on: database)
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
    static func create(name: String, clientID: UUID = UUID(), on database: Database) async throws -> Event {
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


extension Message {
    static func create(title: String, content: String, sender: User, receiver: User, on database: Database) async throws -> Message {
        let message = Message(title: title, content: content, dateSent: Date.now,
                              senderID: try sender.requireID(), senderMail: sender.email,
                              receiverID: try receiver.requireID(), receiverMail: receiver.email)
        try await message.save(on: database)
        return message
    }
    
    static func deleteAll(on database: Database) async throws {
        try await Message.query(on: database)
            .withDeleted()
            .all()
            .delete(force: true, on: database)
    }
}

extension Module {
    static func create(name: String, index: Int, on database: Database) async throws -> Module {
        let module = Module(name: name, index: index)
        try await module.save(on: database)
        return module
    }
    
    static func deleteAll(on database: Database) async throws {
        try await Module.query(on: database)
            .withDeleted()
            .all()
            .delete(force: true, on: database)
    }
}

extension PasswordResetToken {
    static func create(for user: User, expiresAt date: Date = Date().addingTimeInterval(3600), on database: Database) async throws -> PasswordResetToken {
        let token = PasswordResetToken.generate()
        let resetToken = PasswordResetToken(token: token, userId: try user.requireID(), userEmail: user.email, expiresAt: date)
        try await resetToken.save(on: database)
        return resetToken
    }
    
    static func deleteAll(on database: Database) async throws {
        try await PasswordResetToken.query(on: database)
            .withDeleted()
            .all()
            .delete(force: true, on: database)
    }
}
