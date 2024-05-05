//
//  Form.swift
//
//
//  Created by Raphaël Payet on 05/05/2024.
//

import Vapor
import Fluent

final class Form: Model, Content {
    static let schema = Form.v20240207.schemaName

    @ID
    var id: UUID?

    @Field(key: Form.v20240207.title)
    var title: String
    
    @Field(key: Form.v20240207.createdBy)
    var createdBy: String?
    
    @Timestamp(key: Form.v20240207.createdAt, on: .create)
    var createdAt: Date?
    
    @Field(key: Form.v20240207.updatedBy)
    var updatedBy: String?
    
    @Timestamp(key: Form.v20240207.updatedAt, on: .update)
    var updatedAt: Date?
    
    @Field(key: Form.v20240207.value)
    var value: String

    @Field(key: Form.v20240207.clientID)
    var clientID: String
    
    init() {}
    
    init(
        id: UUID? = nil,
        title: String, value: String, clientID: String,
        createdBy: String? = nil, createdAt: Date? = nil,
        updatedBy: String? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.title = title
        self.value = value
        self.clientID = clientID
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.updatedBy = updatedBy
        self.updatedAt = updatedAt
    }
    
    struct CreationInput: Content {
        let title: String
        let createdBy: String
        let value: String
        let clientID: String
    }
    
    struct UpdateInput: Content {
        let updatedBy: String
        let value: String
    }
}

extension Form {
    enum v20240207 {
        static let schemaName = "forms"
        static let id = FieldKey(stringLiteral: "id")
        static let title = FieldKey(stringLiteral: "title")
        static let value = FieldKey(stringLiteral: "value")
        static let clientID = FieldKey(stringLiteral: "clientID")
        static let createdAt = FieldKey(stringLiteral: "createdAt")
        static let createdBy = FieldKey(stringLiteral: "createdBy")
        static let updatedAt = FieldKey(stringLiteral: "updatedAt")
        static let updatedBy = FieldKey(stringLiteral: "updatedBy")
    }
}
