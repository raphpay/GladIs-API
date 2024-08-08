//
//  Processus.swift
//
//
//  Created by Raphaël Payet on 06/08/2024.
//

import Vapor
import Fluent

final class Processus: Model, Content, @unchecked Sendable {
    static let schema = Processus.v20240806.schemaName

    @ID
    var id: UUID?

    @Field(key: Processus.v20240806.title)
    var title: String
    
    @Field(key: Processus.v20240806.number)
    var number: Int
    
    @Field(key: Processus.v20240806.folder)
    var folder: Folder
    
    @Parent(key: Processus.v20240806.user)
    var user: User
    
    init() {}
    
    init(id: UUID? = nil, title: String, number: Int, folder: Folder, userID: User.IDValue) {
        self.id = id
        self.title = title
        self.number = number
        self.folder = folder
        self.$user.id = userID
    }
}
