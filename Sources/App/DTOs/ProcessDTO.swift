//
//  ProcessDTO.swift
//
//
//  Created by Raphaël Payet on 06/08/2024.
//

import Fluent
import Vapor

extension Process {
    enum Folder: String, Codable {
        case systemQuality, record
    }
    
    struct Input: Content {
        let title: String
        let number: Int
        let userID: User.IDValue
        let folder: Folder
        
        func validate(on db: Database) async throws -> User {
            guard let user = try await User.find(userID, on: db) else {
                throw Abort(.notFound, reason: "notFound.user")
            }
            
            return user
        }
        
        func toModel() -> Process {
            .init(title: title, number: number, folder: folder, userID: userID)
        }
    }
}
