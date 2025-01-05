//
//  RemoveParameterToVersionLog.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 05/01/2025.
//

import Fluent
import Vapor

struct RemoveParameterToVersionLog: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(VersionLog.v20241227.schemaName)
            .id()
            .deleteField(VersionLog.v20241227.supportedClientVersions)
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema(VersionLog.v20241227.schemaName)
            .field(VersionLog.v20241227.supportedClientVersions, .array(of: .string), .required)
            .update()
    }
}
