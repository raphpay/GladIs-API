//
//  DocumentActivityLog.swift
//
//
//  Created by Raphaël Payet on 29/02/2024.
//

import Vapor
import Fluent

final class DocumentActivityLog: Model, Content {
    static let schema = DocumentActivityLog.v20240207.schemaName

    @ID
    var id: UUID?

    @Field(key: DocumentActivityLog.v20240207.name)
    var name: String
    
    @Field(key: DocumentActivityLog.v20240207.actorUsername)
    var actorUsername: String
    
    @Field(key: DocumentActivityLog.v20240207.actionDate)
    var actionDate: Date
    
    @Field(key: DocumentActivityLog.v20240207.actorIsAdmin)
    var actorIsAdmin: Bool
    
    @Parent(key: DocumentActivityLog.v20240207.documentID)
    var document: Document
    
    @Parent(key: DocumentActivityLog.v20240207.clientID)
    var client: User
    
    @Enum(key: DocumentActivityLog.v20240207.actionEnum)
    var action: DocumentActivityLog.ActionEnum
    
    init() {}
    
    init(id: UUID? = nil, name: String, actorUsername: String,
         action: DocumentActivityLog.ActionEnum, actionDate: Date, actorIsAdmin: Bool,
         documentID: Document.IDValue, clientID: User.IDValue) {
        self.id = id
        self.name = name
        self.actorUsername = actorUsername
        self.action = action
        self.actionDate = actionDate
        self.actorIsAdmin = actorIsAdmin
        self.$document.id = documentID
        self.$client.id = clientID
    }
    
    final class Input: Content {
        var id: UUID?
        var action: DocumentActivityLog.ActionEnum
        var actorIsAdmin: Bool
        var actorID: UUID
        var documentID: UUID
        var clientID: UUID
        
        init(id: UUID? = nil, action: DocumentActivityLog.ActionEnum,
             actorIsAdmin: Bool, actorID: UUID, clientID: UUID, documentID: UUID) {
            self.id = id
            self.action = action
            self.actorIsAdmin = actorIsAdmin
            self.actorID = actorID
            self.clientID = clientID
            self.documentID = documentID
        }
    }
}

extension DocumentActivityLog {
    enum v20240207 {
        static let schemaName = "documentActivityLogs"
        static let id = FieldKey(stringLiteral: "id")
        static let name = FieldKey(stringLiteral: "name")
        static let actorUsername = FieldKey(stringLiteral: "actorUsername")
        static let actionDate = FieldKey(stringLiteral: "actionDate")
        static let actorIsAdmin = FieldKey(stringLiteral: "actorIsAdmin")
        static let documentID = FieldKey(stringLiteral: "documentID")
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
