//
//  Message.swift
//  
//
//  Created by Raphaël Payet on 29/03/2024.
//

import Vapor
import Fluent

final class Message: Model, Content {
    static let schema = Message.v20240207.schemaName

    @ID
    var id: UUID?

    @Field(key: Message.v20240207.title)
    var title: String
    
    @Field(key: Message.v20240207.content)
    var content: String
    
    @Field(key: Message.v20240207.dateSent)
    var dateSent: Date

    @Parent(key: Message.v20240207.senderID)
    var sender: User
    
    @Parent(key: Message.v20240207.receiverID)
    var receiver: User
    
    init() {}
    
    init(id: UUID? = nil, title: String, content: String, dateSent: Date, senderID: User.IDValue, receiverID: User.IDValue) {
        self.id = id
        self.content = content
        self.title = title
        self.dateSent = dateSent
        self.$sender.id = senderID
        self.$receiver.id = receiverID
    }
    
    struct Input: Content {
        let title: String
        let content: String
        let senderID: User.IDValue
        let receiverID: User.IDValue
    }
}

extension Message {
    enum v20240207 {
        static let schemaName = "messages"
        static let id = FieldKey(stringLiteral: "id")
        static let content = FieldKey(stringLiteral: "content")
        static let title = FieldKey(stringLiteral: "title")
        static let dateSent = FieldKey(stringLiteral: "dateSent")
        static let senderID = FieldKey(stringLiteral: "senderID")
        static let receiverID = FieldKey(stringLiteral: "receiverID")
    }
}

