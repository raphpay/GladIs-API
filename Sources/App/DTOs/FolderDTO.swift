//
//  FolderDTO.swift
//
//
//  Created by Raphaël Payet on 06/08/2024.
//

import Fluent
import Vapor

// MARK: - Get
extension Folder {
    struct Input: Content {
        let title: String
        let number: Int
        let userID: User.IDValue
        let sleeve: Sleeve
        let path: String?
        let category: Category
        
        func toModel() -> Folder {
            .init(title: title,
                  number: number,
                  sleeve: sleeve,
                  category: category,
                  path: path,
                  userID: userID
            )
        }
    }
    
    struct MultipleInput: Content {
        let inputs: [Input]
        let userID: User.IDValue
    }
}

// MARK: - Update
extension Folder {
    struct UpdateInput: Content {
        let title: String?
        let number: Int?
        let path: String?
        let category: Category?
        
        func update(_ folder: Folder, on req: Request) async throws -> Folder {
            let updatedFolder = folder
            
            if let title = title {
                updatedFolder.title = title
            }
            if let number = number {
                updatedFolder.number = number
            }
            if let path = path {
                updatedFolder.path = path
            }
            
            if let category = category {
                updatedFolder.category = category
            }
            
            try await updatedFolder.update(on: req.db)
            
            return updatedFolder
        }
    }
}

// MARK: - Get
extension Folder {
    struct UserRecordPathInput: Content {
        let path: String
    }
}
