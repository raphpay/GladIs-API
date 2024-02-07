//
//  CreateUser.swift
//  
//
//  Created by Raphaël Payet on 07/02/2024.
//

import Fluent
import Vapor

struct CreateUser: Migration {
    func prepare(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database
            .enum(User.v20240207.userType)
            .case(User.v20240207.admin)
            .case(User.v20240207.standard)
            .case(User.v20240207.restricted)
            .create()
            .flatMap { userType in
                database.schema(User.v20240207.schemaName)
                    .id()
                    .field(User.v20240207.identifier, .string, .required)
                    .field(User.v20240207.email, .string, .required)
                    .field(User.v20240207.password, .string, .required)
                    .field("userType", userType, .required)
                    .unique(on: User.v20240207.identifier)
                    .create()
        }

    }
    
    func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database
            .schema(User.v20240207.schemaName)
            .delete()
    }
}

extension User {
    enum v20240207 {
        static let schemaName = "users"
        static let id = FieldKey(stringLiteral: "id")
        static let firstName = FieldKey(stringLiteral: "firstName")
        static let lastName = FieldKey(stringLiteral: "lastName")
        static let email = FieldKey(stringLiteral: "email")
        static let identifier = FieldKey(stringLiteral: "identifier")
        static let password = FieldKey(stringLiteral: "password")
        static let userType = "userType"
        static let admin = "admin"
        static let standard = "standard"
        static let restricted = "restricted"
    }
}
