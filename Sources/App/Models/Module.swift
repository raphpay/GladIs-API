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

    init() {}
    
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

extension Module {
    enum v20240207 {
        static let schemaName = "modules"
        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "name")
    }
}