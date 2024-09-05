//
//  File.swift
//  
//
//  Created by Raphaël Payet on 08/08/2024.
//

@testable import App
import XCTVapor
import Fluent

extension FolderControllerTests {
    func saveProcess(to admin: User, folder: [Folder], sleeve: Folder.Sleeve, on db: Database) async throws {
        if sleeve == .systemQuality {
            admin.systemQualityFolders = folder
        } else {
            admin.recordsFolders = folder
        }
        try await admin.update(on: db)
    }
    
    func createExpectedFolder(with userID: User.IDValue, on db: Database) async throws -> Folder {
        let folder = Folder(title: expectedTitle, number: expectedNumber, sleeve: expectedSleeve, userID: userID)
        try await folder.save(on: db)
        return folder
    }
    
    func createExpectedFolder(for user: User, in sleeve: Folder.Sleeve, on db: Database) async throws -> Folder {
        let userID = try user.requireID()
        let folder = Folder(title: expectedTitle, number: expectedNumber, sleeve: expectedSleeve, userID: userID)
        
        if sleeve == .systemQuality {
            user.systemQualityFolders = [folder]
        } else if sleeve == .record {
            user.recordsFolders = [folder]
        }
        
        try await user.update(on: db)
        
        try await folder.save(on: db)
        return folder
    }
}
