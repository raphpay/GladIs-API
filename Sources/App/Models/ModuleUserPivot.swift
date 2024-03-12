//
//  ModuleUserPivot.swift
//  
//
//  Created by Raphaël Payet on 07/02/2024.
//

import Fluent
import Vapor

final class ModuleUserPivot: Model, Content {
    static let schema: String = ModuleUserPivot.v20240207.schemaName
    
    @ID
    var id: UUID?
    
    @Parent(key: ModuleUserPivot.v20240207.moduleID)
    var module: Module
    
    @Parent(key: ModuleUserPivot.v20240207.userID)
    var user: User
    
    init() {}
    
    init(id: UUID? = nil, module: Module, user: User) throws {
        self.id = id
        self.$module.id = try module.requireID()
        self.$user.id = try user.requireID()
    }
}

extension ModuleUserPivot {
    enum v20240207 {
        static let schemaName = "module-user-pivot"
        static let moduleID = FieldKey(stringLiteral: "moduleID")
        static let userID = FieldKey(stringLiteral: "userID")
    }
}
