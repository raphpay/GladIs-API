//
//  DocumentDTO.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 18/10/2024.
//

import Vapor

extension Document {
    struct Input: Content {
        let id: UUID?
        let name: String
        let path: String
        let lastModified: Date?
        let file : File
    }
    
    struct StatusInput: Content {
        let status: Status
    }
    
    struct PaginatedOutput: Content {
        let documents: [Document]
        let pageCount: Int
    }
    
    struct FormDataInput: Content {
        let uri: String
        let name: String
        let path: String
        
        func toBaseInput(file: File) -> Document.Input {
            .init(id: nil, name: name, path: path, lastModified: .now, file: file)
        }
    }

    struct SearchInput: Content {
        let name: String
        let path: String
    }
    
    struct PathInput: Content {
        let path: String
    }
}
