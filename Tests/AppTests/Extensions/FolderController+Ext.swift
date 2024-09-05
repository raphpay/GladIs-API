//
//  FolderController+Ext.swift
//  
//
//  Created by Raphaël Payet on 05/09/2024.
//

@testable import App
import XCTVapor
import Fluent

extension Folder {
    static func reset(on db: Database) async throws {
        try await Folder
            .query(on: db)
            .all()
            .delete(force: true, on: db)
    }
}
