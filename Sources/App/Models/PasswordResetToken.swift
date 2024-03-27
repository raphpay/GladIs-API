//
//  PasswordResetToken.swift
//
//
//  Created by Raphaël Payet on 26/03/2024.
//

import Fluent
import Vapor

final class PasswordResetToken: Model, Content {
    static let schema = PasswordResetToken.v20240207.schemaName
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: PasswordResetToken.v20240207.token)
    var token: String

    @Parent(key: PasswordResetToken.v20240207.userID)
    var user: User

    @Field(key: PasswordResetToken.v20240207.expiresAt)
    var expiresAt: Date
    
    init() { }

    init(id: UUID? = nil, token: String, userId: User.IDValue, expiresAt: Date) {
        self.id = id
        self.token = token
        self.$user.id = userId
        self.expiresAt = expiresAt
    }
}

extension PasswordResetToken {
    enum v20240207 {
        static let schemaName = "password_reset_tokens"
        static let id = FieldKey(stringLiteral: "id")
        static let token = FieldKey(stringLiteral: "token")
        static let userID = FieldKey(stringLiteral: "userID")
        static let expiresAt = FieldKey(stringLiteral: "expiresAt")
    }
}
