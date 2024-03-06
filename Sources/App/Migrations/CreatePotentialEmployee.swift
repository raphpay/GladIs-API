//
//  CreatePotentialEmployee.swift
//
//
//  Created by Raphaël Payet on 06/03/2024.
//

import Fluent

struct CreatePotentialEmployee: Migration {
    func prepare(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database
            .schema(PotentialEmployee.v20240207.schemaName)
            .id()
            .field(PotentialEmployee.v20240207.firstName, .string, .required)
            .field(PotentialEmployee.v20240207.lastName, .string, .required)
            .field(PotentialEmployee.v20240207.companyName, .string, .required)
            .field(PotentialEmployee.v20240207.pendingUserID, .uuid, .required)
            .create()
    }
    
    func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database
            .schema(PotentialEmployee.v20240207.schemaName)
            .delete()
    }
}
