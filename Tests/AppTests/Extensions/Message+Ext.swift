//
//  Message+Ext.swift
//  
//
//  Created by Raphaël Payet on 05/09/2024.
//

@testable import App
import XCTVapor
import Fluent

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
