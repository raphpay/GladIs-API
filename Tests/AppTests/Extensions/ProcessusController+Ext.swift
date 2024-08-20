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
    
    func createExpectedProcessus(with userID: User.IDValue, on db: Database) async throws -> Processus {
        let processus = Processus(title: expectedTitle, number: expectedNumber, folder: expectedFolder, userID: userID)
        try await processus.save(on: db)
        return processus
    }
    
    func createExpectedProcessus(for user: User, in folder: Processus.Folder, on db: Database) async throws -> Processus {
        let userID = try user.requireID()
        let processus = Processus(title: expectedTitle, number: expectedNumber, folder: expectedFolder, userID: userID)
        
        if folder == .systemQuality {
            user.systemQualityFolders = [processus]
        } else if folder == .record {
            user.recordsFolders = [processus]
        }
        
        try await user.update(on: db)
        
        try await processus.save(on: db)
        return processus
    }
}
