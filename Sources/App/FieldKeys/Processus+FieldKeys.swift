//
//  Processus+FieldKeys.swift
//  
//
//  Created by Raphaël Payet on 06/08/2024.
//

import Fluent

extension Processus {
    enum v20240806 {
        static let schemaName = "processes"
        static let id = FieldKey(stringLiteral: "id")
        static let title = FieldKey(stringLiteral: "title")
        static let number = FieldKey(stringLiteral: "number")
        static let folder = FieldKey(stringLiteral: "folder")
        static let userID = FieldKey(stringLiteral: "userID")
    }
}
