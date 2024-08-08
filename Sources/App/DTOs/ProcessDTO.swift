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
}
