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
        
        static let status = FieldKey(stringLiteral: "status")
    }
}
