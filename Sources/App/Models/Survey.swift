//
//  Survey.swift
//
//
//  Created by Raphaël Payet on 23/04/2024.
//

import Vapor
import Fluent

final class Survey: Model, Content {
    static let schema = Survey.v20240207.schemaName

    @ID
    var id: UUID?

    @Field(key: Survey.v20240207.value)
    var value: String
    
    @Timestamp(key: Survey.v20240207.createdAt, on: .create, format: .iso8601)
    var createdAt: Date?
    
    @Timestamp(key: Survey.v20240207.updatedAt, on: .update, format: .iso8601)
    var updatedAt: Date?

    @Parent(key: Survey.v20240207.clientID)
    var client: User

    init() {}

    init(id: UUID? = nil, value: String, clientID: User.IDValue) {
        self.id = id
        self.value = value
        self.$client.id = clientID
    }
    
    struct Input: Content {
        let value: String
        let clientID: User.IDValue
    }
    
    struct UpdateInput: Content {
        let value: String
    }
}

extension Survey {
    enum v20240207 {
        static let schemaName = "surveys"
        static let id = FieldKey(stringLiteral: "id")
        static let value = FieldKey(stringLiteral: "value")
        static let createdAt = FieldKey(stringLiteral: "createdAt")
        static let updatedAt = FieldKey(stringLiteral: "updatedAt")
        static let clientID = FieldKey(stringLiteral: "clientID")
    }
}

