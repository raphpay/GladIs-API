//
//  File.swift
//  
//
//  Created by Raphaël Payet on 08/08/2024.
//

@testable import App
import XCTVapor
import Fluent

extension ProcessusControllerTests {
    func saveProcess(to admin: User, processus: [Processus], folder: Processus.Folder, on db: Database) async throws {
        if folder == .systemQuality {
            admin.systemQualityFolders = processus
        } else {
            admin.recordsFolders = processus
        }
        try await admin.update(on: db)
    }
}
