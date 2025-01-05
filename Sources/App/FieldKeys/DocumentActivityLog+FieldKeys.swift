//
//  DocumentActivityLog+FieldKeys.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 05/01/2025.
//

import Fluent

extension DocumentActivityLog {
    enum v20240207 {
        static let schemaName = "documentActivityLogs"
        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "name")
        static let actorUsername = FieldKey(stringLiteral: "actorUsername")
        static let actionDate = FieldKey(stringLiteral: "actionDate")
        static let actorIsAdmin = FieldKey(stringLiteral: "actorIsAdmin")
        static let documentID = FieldKey(stringLiteral: "documentID")
        static let formID = FieldKey(stringLiteral: "formID")
        static let clientID = FieldKey(stringLiteral: "clientID")
        
        static let actionEnum = FieldKey(stringLiteral: "actionEnum")
        static let action = "action"
        static let creation = "creation"
        static let modification = "modification"
        static let approbation = "approbation"
        static let visualisation = "visualisation"
        static let loaded = "loaded"
        static let deletion = "deletion"
        static let signature = "signature"
    }
    
    enum ActionEnum: String, Codable {
        case creation, modification, approbation
        case visualisation, loaded, deletion
        case signature
    }
}
