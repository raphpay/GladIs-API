//
//  TechnicalDocumentationTab.swift
//
//
//  Created by Raphaël Payet on 29/02/2024.
//

import Vapor
import Fluent

final class TechnicalDocumentationTab: Model, Content {
    static let schema = TechnicalDocumentationTab.v20240207.schemaName

    @ID
    var id: UUID?

    @Field(key: TechnicalDocumentationTab.v20240207.name)
    var name: String
    
    init() {}
    
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
    
    final class Input: Content {
        var id: UUID?
        var name: String
        
        init(id: UUID? = nil, name: String) {
            self.id = id
            self.name = name
        }
    }
}

extension TechnicalDocumentationTab {
    enum v20240207 {
        static let schemaName = "technicalDocumentationTabs"
        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "name")
    }
}
