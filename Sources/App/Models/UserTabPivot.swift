//
//  UserTabPivot.swift
//
//
//  Created by Raphaël Payet on 29/02/2024.
//

import Fluent
import Vapor

final class UserTabPivot: Model, Content {
    static let schema: String = UserTabPivot.v20240207.schemaName
    
    @ID
    var id: UUID?
    
    @Parent(key: UserTabPivot.v20240207.userID)
    var user: User
    
    @Parent(key: UserTabPivot.v20240207.tabID)
    var technicalDocumentationTab: TechnicalDocumentationTab
    
    init() {}
    
    init(id: UUID? = nil, user: User, technicalDocumentationTab: TechnicalDocumentationTab) throws {
        self.id = id
        self.$user.id = try user.requireID()
        self.$technicalDocumentationTab.id = try technicalDocumentationTab.requireID()
    }
}

extension UserTabPivot {
    enum v20240207 {
        static let schemaName = "user-tab-pivot"
        static let userID = FieldKey(stringLiteral: "userID")
        static let tabID = FieldKey(stringLiteral: "tabID")
    }
}
