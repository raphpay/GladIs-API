//
//  Document+FieldKeys.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 18/10/2024.
//

import Fluent

extension Document {
    enum v20240207 {
        static let schemaName = "documents"
        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "name")
        static let path = FieldKey(stringLiteral: "path")
        static let lastModified = FieldKey(stringLiteral: "lastModified")
        
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
