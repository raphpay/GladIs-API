//
//  Token.swift
//  
//
//  Created by Raphaël Payet on 07/02/2024.
//

import Vapor
import Fluent

final class Token: Model, Content {
    static let schema = Token.v20240207.schemaName

    @ID
    var id: UUID?

    @Field(key: Token.v20240207.value)
    var value: String

    @Parent(key: Token.v20240207.userID)
    var user: User

    init() {}

    init(id: UUID? = nil, value: String, userID: User.IDValue) {
        self.id = id
        self.value = value
        self.$user.id = userID
    }
}

extension Token {
    enum v20240207 {
        static let schemaName = "tokens"
        static let id = FieldKey(stringLiteral: "id")
        static let value = FieldKey(stringLiteral: "value")
        static let userID = FieldKey(stringLiteral: "userID")
    }
}
