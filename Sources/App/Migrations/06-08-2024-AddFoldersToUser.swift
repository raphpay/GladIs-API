//
//  06-08-2024-AddFoldersToUser.swift
//
//
//  Created by Raphaël Payet on 06/08/2024.
//

import Fluent
import Vapor

struct AddFoldersToUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(User.v20240207.schemaName)
            .id()
            .field(User.v20240806.systemQualityFolders, .array(of: .custom([Process.self])))
            .field(User.v20240806.recordsFolders, .array(of: .custom([Process.self])))
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema(User.v20240207.schemaName)
            .deleteField(User.v20240806.systemQualityFolders)
            .deleteField(User.v20240806.recordsFolders)
            .update()
    }
}
