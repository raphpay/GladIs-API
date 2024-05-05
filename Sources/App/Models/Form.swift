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
    
    init() {}
    
    init(id: UUID? = nil, title: String, createdBy: String? = nil, createdAt: Date? = nil, updatedBy: String? = nil, updatedAt: Date? = nil, value: String) {
        self.id = id
        self.title = title
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.updatedBy = updatedBy
        self.updatedAt = updatedAt
        self.value = value
    }
    
    struct CreationInput: Content {
        let title: String
        let createdBy: String
        let value: String
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
        static let createdAt = FieldKey(stringLiteral: "createdAt")
        static let createdBy = FieldKey(stringLiteral: "createdBy")
        static let updatedAt = FieldKey(stringLiteral: "updatedAt")
        static let updatedBy = FieldKey(stringLiteral: "updatedBy")
        static let value = FieldKey(stringLiteral: "value")
    }
}
