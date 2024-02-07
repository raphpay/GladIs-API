//
//  CreateModule.swift
//
//
//  Created by Raphaël Payet on 07/02/2024.
//

import Fluent

struct CreateModule: Migration {
    func prepare(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database
            .schema(Module.v20240207.schemaName)
            .field(Module.v20240207.name, .string, .required)
//            .field(User.v20240207.id, .uuid, .required,
//                   .references(User.v20240207.schemaName, User.v20240207.id, onDelete: .cascade))
            .create()
    }
    
    func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database
            .schema(Module.v20240207.schemaName)
            .delete()
    }
}
