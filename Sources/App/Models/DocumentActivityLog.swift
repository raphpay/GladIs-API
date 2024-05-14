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
    
    @OptionalParent(key: DocumentActivityLog.v20240207.documentID)
    var document: Document?
    
    @OptionalParent(key: DocumentActivityLog.v20240207.formID)
    var form: Form?
    
    @Parent(key: DocumentActivityLog.v20240207.clientID)
    var client: User
    
    @Enum(key: DocumentActivityLog.v20240207.actionEnum)
    var action: DocumentActivityLog.ActionEnum
    
    init() {}
    
    init(id: UUID? = nil, name: String, actorUsername: String,
         action: DocumentActivityLog.ActionEnum, actionDate: Date, actorIsAdmin: Bool,
         documentID: Document.IDValue? = nil, formID: Form.IDValue? = nil, clientID: User.IDValue) {
        self.id = id
        self.name = name
        self.actorUsername = actorUsername
        self.action = action
        self.actionDate = actionDate
        self.actorIsAdmin = actorIsAdmin
        self.$document.id = documentID
        self.$form.id = formID
        self.$client.id = clientID
    }
    
    struct Input: Content {
        var id: UUID?
        let action: DocumentActivityLog.ActionEnum
        let actorIsAdmin: Bool
        let actorID: UUID
        let documentID: Document.IDValue?
        let formID: Form.IDValue?
        let clientID: User.IDValue
    }

    struct PaginatedOutput: Content {
        let logs: [DocumentActivityLog]
        let pageCount: Int
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
