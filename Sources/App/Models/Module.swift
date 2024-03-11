//
//  Module.swift
//
//
//  Created by Raphaël Payet on 07/02/2024.
//

import Vapor
import Fluent

final class Module: Model, Content {
    static let schema = Module.v20240207.schemaName

    @ID
    var id: UUID?

    @Field(key: Module.v20240207.name)
    var name: String
    
    @Field(key: Module.v20240207.index)
    var index: Int

    init() {}
    
    init(id: UUID? = nil, name: String, index: Int) {
        self.id = id
        self.name = name
        self.index = index
    }
    
    struct Input: Content {
        var id: UUID?
        let name: String
        let index: Int
    }
}

extension Module {
    enum v20240207 {
        static let schemaName = "modules"
        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "name")
        static let index = FieldKey(stringLiteral: "index")
    }
}
