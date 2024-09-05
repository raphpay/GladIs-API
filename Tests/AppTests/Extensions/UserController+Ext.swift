//
//  UserController+Ext.swift
//
//
//  Created by Raphaël Payet on 05/09/2024.
//

@testable import App
import XCTVapor
import Fluent

extension User {
    static func reset(on db: Database) async throws {
        try await User
            .query(on: db)
            .all()
            .delete(force: true, on: db)
    }
}
