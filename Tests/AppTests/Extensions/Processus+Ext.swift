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
    func createExpectedFolder(with userID: User.IDValue,
                              on db: Database
    ) async throws -> Folder {
        let folder = Folder(title: expectedTitle,
                            number: expectedNumber,
                            sleeve: expectedSleeve,
                            category: expectedCategory,
                            userID: userID)
        try await folder.save(on: db)
        return folder
    }
    
    func createExpectedFolder(for user: User,
                              in sleeve: Folder.Sleeve,
                              on db: Database
    ) async throws -> Folder {
        let userID = try user.requireID()
        let folder = Folder(title: expectedTitle,
                            number: expectedNumber,
                            sleeve: expectedSleeve,
                            category: expectedCategory,
                            userID: userID)
        
        try await folder.save(on: db)
        return folder
    }
}
