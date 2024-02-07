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
                    .field(User.v20240207.username, .string, .required)
                    .field(User.v20240207.email, .string, .required)
                    .field(User.v20240207.password, .string, .required)
                    .field("userType", userType, .required)
                    .unique(on: User.v20240207.username)
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
        static let username = FieldKey(stringLiteral: "username")
        static let password = FieldKey(stringLiteral: "password")
        static let phoneNumber = FieldKey(stringLiteral: "phoneNumber")
        static let products = FieldKey(stringLiteral: "products")
        static let modules = FieldKey(stringLiteral: "modules")
        static let userType = "userType"
        static let admin = "admin"
        static let standard = "standard"
        static let restricted = "restricted"
    }
}
