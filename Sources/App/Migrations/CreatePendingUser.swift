//
//  CreatePendingUser.swift
//
//
//  Created by Raphaël Payet on 12/02/2024.
//

import Foundation

import Fluent

struct CreatePendingUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        
        let status = try await database.enum(PendingUser.v20240207.status)
            .case(PendingUser.v20240207.pending)
            .case(PendingUser.v20240207.inReview)
            .case(PendingUser.v20240207.accepted)
            .case(PendingUser.v20240207.rejected)
            .create()
        
        try await database.schema(PendingUser.v20240207.schemaName)
            .id()
            .field(PendingUser.v20240207.firstName, .string, .required)
            .field(PendingUser.v20240207.lastName, .string, .required)
            .field(PendingUser.v20240207.companyName, .string, .required)
            .field(PendingUser.v20240207.email, .string, .required)
            .field(PendingUser.v20240207.products, .string)
            .field(PendingUser.v20240207.numberOfEmployees, .int16)
            .field(PendingUser.v20240207.numberOfUsers, .int16)
            .field(PendingUser.v20240207.salesAmount, .double)
            .field(PendingUser.v20240207.statusEnum, status, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database
            .schema(PendingUser.v20240207.schemaName)
            .delete()
    }
}
