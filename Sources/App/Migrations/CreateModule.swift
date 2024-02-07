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
            .unique(on: Module.v20240207.name)
            .create()
    }
    
    func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database
            .schema(Module.v20240207.schemaName)
            .delete()
    }
}
