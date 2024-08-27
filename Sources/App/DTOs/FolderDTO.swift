//
//  ProcessDTO.swift
//
//
//  Created by Raphaël Payet on 06/08/2024.
//

import Fluent
import Vapor

extension Folder {
    enum Sleeve: String, Codable {
        case systemQuality, record
    }
    
    struct Input: Content {
        let title: String
        let number: Int
        let userID: User.IDValue
        let sleeve: Sleeve
        
        func toModel() -> Folder {
            .init(title: title, number: number, sleeve: sleeve, userID: userID)
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
        
        func update(_ folder: Folder, on req: Request) async throws -> Folder {
            let updatedFolder = folder
            
            if let title = title {
                updatedFolder.title = title
            }
            if let number = number {
                updatedFolder.number = number
            }
            
            try await updatedFolder.update(on: req.db)
            
            return updatedFolder
        }
    }
}
