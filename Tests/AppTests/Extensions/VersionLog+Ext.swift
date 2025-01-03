//
//  VersionLog+Ext.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 27/12/2024.
//

@testable import App
import Fluent
import Vapor

extension VersionLogControllerTests {
    func createExpectedVersionLog(on db: Database) async throws -> VersionLog {
        let versionLog = VersionLog(currentVersion: expectedCurrentVersion,
                                    supportedClientVersions: expectedSupportedClientVersions,
                                    minimumClientVersion: expectedMinimumVersion)
        try await versionLog.save(on: db)
        return versionLog
    }
}

extension VersionLog {
    static func deleteAll(on database: Database) async throws {
        try await VersionLog.query(on: database)
            .withDeleted()
            .all()
            .delete(force: true, on: database)
    }
}
