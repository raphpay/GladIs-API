//
//  Survey+Ext.swift
//  
//
//  Created by Raphaël Payet on 05/09/2024.
//

@testable import App
import XCTVapor
import Fluent

extension Survey {
    static func create(value: String, clientID: User.IDValue, on database: Database) async throws -> Survey {
        let survey = Survey(value: value, clientID: clientID)
        try await survey.save(on: database)
        return survey
    }
    
    static func deleteAll(on database: Database) async throws {
        try await Survey.query(on: database)
            .withDeleted()
            .all()
            .delete(force: true, on: database)
    }
}
