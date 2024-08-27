//
//  Processus.swift
//
//
//  Created by Raphaël Payet on 06/08/2024.
//

import Vapor
import Fluent

final class Folder: Model, Content, @unchecked Sendable {
    static let schema = Folder.v20240806.schemaName

    @ID
    var id: UUID?

    @Field(key: Folder.v20240806.title)
    var title: String
    
    @Field(key: Folder.v20240806.number)
    var number: Int
    
    @Field(key: Folder.v20240806.sleeve)
    var sleeve: Sleeve
    
    @Parent(key: Folder.v20240806.userID)
    var user: User
    
    init() {}
    
    init(id: UUID? = nil, title: String, number: Int, sleeve: Sleeve, userID: User.IDValue) {
        self.id = id
        self.title = title
        self.number = number
        self.sleeve = sleeve
        self.$user.id = userID
    }
}
