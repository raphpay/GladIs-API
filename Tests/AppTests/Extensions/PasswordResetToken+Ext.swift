//
//  PasswordResetToken+Ext.swift
//
//
//  Created by Raphaël Payet on 05/09/2024.
//

@testable import App
import XCTVapor
import Fluent

extension PasswordResetToken {
    static func create(for user: User, expiresAt date: Date = Date().addingTimeInterval(3600), on database: Database) async throws -> PasswordResetToken {
        let token = PasswordResetToken.generate()
        let resetToken = PasswordResetToken(token: token, userId: try user.requireID(), userEmail: user.email, expiresAt: date)
        try await resetToken.save(on: database)
        return resetToken
    }
    
    static func deleteAll(on database: Database) async throws {
        try await PasswordResetToken.query(on: database)
            .withDeleted()
            .all()
            .delete(force: true, on: database)
    }
}
