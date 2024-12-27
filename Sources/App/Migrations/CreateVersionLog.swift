//
//  CreateVersionLog.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 27/12/2024.
//

import Fluent

struct CreateVersionLog: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(VersionLog.v20241227.schemaName)
            .id()
            .field(VersionLog.v20241227.currentVersion, .string, .required)
            .field(VersionLog.v20241227.supportedClientVersions, .array(of: .string), .required)
            .field(VersionLog.v20241227.minimumClientVersion, .string, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(VersionLog.v20241227.schemaName)
            .delete()
    }
}
