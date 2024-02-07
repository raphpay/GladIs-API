//
//  CreateModuleUserPivot.swift
//
//
//  Created by Raphaël Payet on 07/02/2024.
//

import Fluent

struct CreateModuleUserPivot: Migration {
    func prepare(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database
            .schema(ModuleUserPivot.v20240207.schemaName)
            .id()
            .field(ModuleUserPivot.v20240207.moduleID, .uuid, .required,
                   .references(Module.v20240207.schemaName, Module.v20240207.id))
            .field(ModuleUserPivot.v20240207.userID, .uuid, .required,
                .references(User.v20240207.schemaName, User.v20240207.id))
            .create()
    }
    
    func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
        database
            .schema(ModuleUserPivot.v20240207.schemaName)
            .delete()
    }
}

extension ModuleUserPivot {
    enum v20240207 {
        static let schemaName = "module-user-pivot"
        static let moduleID = FieldKey(stringLiteral: "moduleID")
        static let userID = FieldKey(stringLiteral: "userID")
    }
}
