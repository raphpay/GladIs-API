//
//  MigrateFoldersToRelation.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 27/12/2024.
//

import Fluent
import Vapor

struct MigrateFoldersToRelation: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(User.v20240207.schemaName)
            .deleteField(User.v20240806.systemQualityFolders)
            .deleteField(User.v20240806.recordsFolders)
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Folder.v20240806.schemaName)
            .field(User.v20240806.systemQualityFolders, .array(of: .custom([Folder.self])))
            .field(User.v20240806.recordsFolders, .array(of: .custom([Folder.self])))
            .update()
    }
}
