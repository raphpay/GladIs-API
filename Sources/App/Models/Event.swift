//
//  Event.swift
//
//
//  Created by Raphaël Payet on 26/03/2024.
//

import Vapor
import Fluent

final class Event: Model, Content {
    static let schema = Event.v20240207.schemaName

    @ID
    var id: UUID?

    @Field(key: Event.v20240207.name)
    var name: String
    
    @Field(key: Event.v20240207.date)
    var date: Double

    @Timestamp(key: Event.v20240207.deletedAt, on: .delete)
    var deletedAt: Date?

    @Parent(key: Event.v20240207.clientID)
    var client: User

    init() {}

    init(id: UUID? = nil, name: String, date: Double, clientID: User.IDValue) {
        self.id = id
        self.name = name
        self.date = date
        self.$client.id = clientID
    }
    
    struct Input: Content {
        var id: UUID?
        let name: String
        let date: Double
        let clientID: User.IDValue
    }
}

extension Event {
    enum v20240207 {
        static let schemaName = "events"
        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "name")
        static let deletedAt = FieldKey(stringLiteral: "deleted_at")
        static let clientID = FieldKey(stringLiteral: "clientID")
        static let date = FieldKey(stringLiteral: "date")
    }
}

