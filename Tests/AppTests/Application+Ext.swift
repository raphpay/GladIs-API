//
//  Application+Ext.swift
//
//
//  Created by Raphaël Payet on 16/04/2024.
//

@testable import App
import XCTVapor
import Fluent

extension Token {
    static func create(for user: User, on database: Database) async throws -> Token {
        let token = try Token.generate(for: user)
        try await token.save(on: database)
        return token
    }
    
    static func deleteAll(on database: Database) async throws {
        try await Token.query(on: database)
            .withDeleted()
            .all()
            .delete(force: true, on: database)
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

extension PotentialEmployee {
    static func create(
        firstName: String, lastName: String,
        companyName: String, phoneNumber: String,
        email: String, pendingUserID: PendingUser.IDValue,
        on database: Database) async throws -> PotentialEmployee {
            let employee = PotentialEmployee(firstName: firstName, lastName: lastName, companyName: companyName, phoneNumber: phoneNumber, email: email, pendingUserID: pendingUserID)
            try await employee.save(on: database)
            return employee
        }
    
    static func deleteAll(on database: Database) async throws {
        try await PotentialEmployee.query(on: database)
            .withDeleted()
            .all()
            .delete(force: true, on: database)
    }
}

extension TechnicalDocumentationTab {
    static func create(name: String, area: String, on database: Database) async throws -> TechnicalDocumentationTab {
        let tab = TechnicalDocumentationTab(name: name, area: area)
        try await tab.save(on: database)
        return tab
    }
    
    static func deleteAll(on database: Database) async throws {
        try await TechnicalDocumentationTab.query(on: database)
            .withDeleted()
            .all()
            .delete(force: true, on: database)
    }
}

extension Survey {
    static func create(value: String, clientID: User.IDValue, on database: Database) async throws -> Survey {
        let survey = Survey(value: value, clientID: clientID)
        try await survey.save(on: database)
        return survey
    }
    
    static func deleteAll(on database: Database) async throws {
        try await Survey.query(on: database)
            .withDeleted()
            .all()
            .delete(force: true, on: database)
    }
}

extension Form {
    static func create(
        title: String, value: String,
        clientID: String, path: String,
        on database: Database
    ) async throws -> Form {
        let form = Form(title: title, value: value, clientID: clientID, path: path)
        try await form.save(on: database)
        return form
    }
    
    static func deleteAll(on database: Database) async throws {
        try await Form.query(on: database)
            .withDeleted()
            .all()
            .delete(force: true, on: database)
    }

    static func approveByAdmin(_ form: Form, on database: Database) async throws {
        form.approvedByAdmin = true
        try await form.update(on: database)
    }

    static func deapproveByAdmin(_ form: Form, on database: Database) async throws {
        form.approvedByAdmin = false
        try await form.update(on: database)
    }

    static func approveByClient(_ form: Form, on database: Database) async throws {
        form.approvedByClient = true
        try await form.update(on: database)
    }

    static func deapproveByClient(_ form: Form, on database: Database) async throws {
        form.approvedByClient = false
        try await form.update(on: database)
    }
}
