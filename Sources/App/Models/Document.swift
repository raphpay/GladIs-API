//
//  File.swift
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
    
    init() {}
    
    init(id: UUID? = nil, name: String, path: String) {
        self.id = id
        self.name = name
        self.path = path
    }
    
    final class Input: Content {
        var id: UUID?
        var name: String
        var path: String
        
        init(id: UUID? = nil, name: String, path: String) {
            self.id = id
            self.name = name
            self.path = path
        }
    }
}

struct PDFEntity : Codable {
    var dataString: String
}

extension Document {
    enum v20240207 {
        static let schemaName = "documents"
        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "name")
        static let path = FieldKey(stringLiteral: "path")
    }
}
