//
//  ProcessDTO.swift
//
//
//  Created by Raphaël Payet on 06/08/2024.
//

import Fluent
import Vapor

extension Processus {
    enum Folder: String, Codable {
        case systemQuality, record
    }
    
    struct Input: Content {
        let title: String
        let number: Int
        let userID: User.IDValue
        let folder: Folder
        
        func toModel() -> Processus {
            .init(title: title, number: number, folder: folder, userID: userID)
        }
    }
    
    struct UpdateInput: Content {
        let title: String?
        let number: Int?
        
        func update(_ processus: Processus, on req: Request) async throws -> Processus {
            let updatedProcessus = processus
            
            if let title = title {
                updatedProcessus.title = title
            }
            if let number = number {
                updatedProcessus.number = number
            }
            
            try await updatedProcessus.update(on: req.db)
            
            return updatedProcessus
        }
    }
}
