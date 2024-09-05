//
//  Token+Ext.swift
//  
//
//  Created by Raphaël Payet on 05/09/2024.
//

@testable import App
import XCTVapor
import Fluent

extension Token {
    static func create(for user: User, on database: Database) async throws -> Token {
        let token = try Token.generate(for: user)
        try await token.save(on: database)
        return token
    }
    
    static func deleteAll(on database: Database) async throws {
        try await Token.query(on: database)
            .withDeleted()
            .all()
            .delete(force: true, on: database)
    }
}
