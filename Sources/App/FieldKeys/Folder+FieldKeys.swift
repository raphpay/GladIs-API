//
//  Processus+FieldKeys.swift
//  
//
//  Created by Raphaël Payet on 06/08/2024.
//

import Fluent

extension Folder {
    enum v20240806 {
        static let schemaName = "folders"
        static let id = FieldKey(stringLiteral: "id")
        static let title = FieldKey(stringLiteral: "title")
        static let number = FieldKey(stringLiteral: "number")
        static let sleeve = FieldKey(stringLiteral: "sleeve")
        static let path = FieldKey(stringLiteral: "path")
        static let userID = FieldKey(stringLiteral: "userID")
    }
}
