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
}
