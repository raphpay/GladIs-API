//
//  Token+Ext.swift
//  
//
//  Created by Raphaël Payet on 08/03/2024.
//

import Fluent
import Vapor

extension Token {
    static func generate(for user: User) throws -> Token {
        let random = [UInt8].random(count: 16).base64
        return try Token(value: random, userID: user.requireID())
    }
}

extension Token: ModelTokenAuthenticatable {
    static let valueKey = \Token.$value
    static let userKey = \Token.$user
    
    typealias User = App.User
    
    var isValid: Bool {
        true
    }
}
