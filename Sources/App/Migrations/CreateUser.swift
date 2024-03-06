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
            .case(User.v20240207.client)
            .case(User.v20240207.employee)
            .create()
            .flatMap { userType in
                database.schema(User.v20240207.schemaName)
                    .id()
                    .field(User.v20240207.firstName, .string, .required)
                    .field(User.v20240207.lastName, .string, .required)
                    .field(User.v20240207.phoneNumber, .string, .required)
                    .field(User.v20240207.email, .string, .required)
                    .field(User.v20240207.username, .string, .required)
                    .field(User.v20240207.password, .string, .required)
                    .field(User.v20240207.firstConnection, .bool, .required)
                    .field(User.v20240207.companyName, .string)
                    .field(User.v20240207.products, .string)
                    .field(User.v20240207.numberOfEmployees, .int64)
                    .field(User.v20240207.numberOfUsers, .int64)
                    .field(User.v20240207.salesAmount, .double)
                    .field(User.v20240207.employeesIDs, .array(of: .string))
                    .field(User.v20240207.managerID, .string)
                    .field("userType", userType, .required)
                    .unique(on: User.v20240207.email)
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
