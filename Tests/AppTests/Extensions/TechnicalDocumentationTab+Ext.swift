//
//  TechnicalDocumentationTab+Ext.swift
//
//
//  Created by Raphaël Payet on 05/09/2024.
//

@testable import App
import XCTVapor
import Fluent

extension TechnicalDocumentationTab {
    static func create(name: String, area: String, on database: Database) async throws -> TechnicalDocumentationTab {
        let tab = TechnicalDocumentationTab(name: name, area: area)
        try await tab.save(on: database)
        return tab
    }
    
    static func deleteAll(on database: Database) async throws {
        try await TechnicalDocumentationTab.query(on: database)
            .withDeleted()
            .all()
            .delete(force: true, on: database)
    }
}
