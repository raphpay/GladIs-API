//
//  CreateTechnicalDocumentationTab.swift
//
//
//  Created by Raphaël Payet on 29/02/2024.
//

import Fluent

struct CreateTechnicalDocumentationTab: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(TechnicalDocumentationTab.v20240207.schemaName)
            .id()
            .field(TechnicalDocumentationTab.v20240207.name, .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(TechnicalDocumentationTab.v20240207.schemaName)
            .delete()
    }
}
