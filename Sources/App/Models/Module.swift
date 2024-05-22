//
//  Module.swift
//
//
//  Created by Raphaël Payet on 07/02/2024.
//

import Vapor
import Fluent

final class Module: Content {
    let id: UUID?
    var name: String
    var index: Int

    init(id: UUID? = UUID(), name: String, index: Int) {
        self.id = id
        self.name = name
        self.index = index
    }

    struct Input: Content {
        var name: String
        var index: Int
    }

    struct RemoveInput: Content {
        var name: String
    }
}