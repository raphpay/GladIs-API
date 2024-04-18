//
//  Document.swift
//  
//
//  Created by Raphaël Payet on 22/02/2024.
//

import Vapor
import Fluent

final class Document: Model, Content {
    static let schema = Document.v20240207.schemaName

    @ID
    var id: UUID?

    @Field(key: Document.v20240207.name)
    var name: String
    
    @Field(key: Document.v20240207.path)
    var path: String
    
    @Field(key: Document.v20240207.lastModified)
    var lastModified: Date?
    
    @Field(key: Document.v20240207.isArchived)
    var isArchived: Bool
    
    @Enum(key: "status")
    var status: Status
    
    init() {}
    
    init(id: UUID? = nil, name: String, path: String, lastModified: Date? = .now,  status: Status, isArchived: Bool) {
        self.id = id
        self.name = name
        self.path = path
        self.lastModified = lastModified
        self.status = status
        self.isArchived = isArchived
    }
    
    final class Input: Content {
        var id: UUID?
        var name: String
        var path: String
        var lastModified: Date?
        var file : File
        
        init(id: UUID? = nil, name: String, path: String, lastModified: Date? = .now, file: File) {
            self.id = id
            self.name = name
            self.path = path
            self.lastModified = lastModified
            self.file = file
        }
    }
    
    struct StatusInput: Content {
        let status: Status
    }
    
    struct PaginatedOutput: Content {
        let documents: [Document]
        let pageCount: Int
    }
    
    struct PathInput: Content {
        let value: String
        let unzippedValue: String?
    }
}

extension Document {
    enum v20240207 {
        static let schemaName = "documents"
        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "name")
        static let path = FieldKey(stringLiteral: "path")
        static let lastModified = FieldKey(stringLiteral: "lastModified")
        static let isArchived = FieldKey(stringLiteral: "isArchived")
        
        static let statusEnum = FieldKey(stringLiteral: "statusEnum")
        static let status = "status"
        static let draft = "draft"
        static let pendingReview = "pendingReview"
        static let underReview = "underReview"
        static let approved = "approved"
        static let rejected = "rejected"
        static let archived = "archived"
        static let none = "none"
    }
    
    enum Status: String, Codable {
        case draft, pendingReview, underReview, approved, rejected, archived
        case none
    }
}
