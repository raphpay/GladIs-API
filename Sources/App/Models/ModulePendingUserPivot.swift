//
//  ModulePendingUserPivot.swift
//  
//
//  Created by Raphaël Payet on 12/02/2024.
//

import Fluent
import Vapor

final class ModulePendingUserPivot: Model, Content {
    static let schema: String = ModuleUserPivot.v20240207.schemaName
    
    @ID
    var id: UUID?
    
    @Parent(key: ModulePendingUserPivot.v20240207.moduleID)
    var module: Module
    
    @Parent(key: ModulePendingUserPivot.v20240207.pendingUserID)
    var pendingUser: PendingUser
    
    init() {}
    
    init(id: UUID? = nil, module: Module, pendingUser: User) throws {
        self.id = id
        self.$module.id = try module.requireID()
        self.$pendingUser.id = try pendingUser.requireID()
    }
}

extension ModulePendingUserPivot {
    enum v20240207 {
        static let schemaName = "module-pending-user-pivot"
        static let moduleID = FieldKey(stringLiteral: "moduleID")
        static let pendingUserID = FieldKey(stringLiteral: "pendingUserID")
    }
}
