//
//  Document.swift
//  
//
//  Created by Raphaël Payet on 22/02/2024.
//

import Vapor
import Fluent

final class Document: Model, Content {
    static let schema = Document.v20240207.schemaName

    @ID
    var id: UUID?

    @Field(key: Document.v20240207.name)
    var name: String
    
    @Field(key: Document.v20240207.path)
    var path: String
    
    @Field(key: Document.v20240207.lastModified)
    var lastModified: Date?
    
    @Enum(key: "status")
    var status: Status
    
    init() {}
    
    init(id: UUID? = nil, name: String, path: String, lastModified: Date? = .now,  status: Status) {
        self.id = id
        self.name = name
        self.path = path
        self.lastModified = lastModified
        self.status = status
    }
}
