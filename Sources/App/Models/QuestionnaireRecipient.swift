//
//  QuestionnaireRecipient.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 22/01/2025.
//

import Vapor
import Fluent

final class QuestionnaireRecipient: Model, Content {
    static let schema = QuestionnaireRecipient.v20240806.schemaName
    
    @ID
    var id: UUID?
    
    @Parent(key: QuestionnaireRecipient.v20240806.questionnaireID)
    var questionnaire: Questionnaire
    
    @Parent(key: QuestionnaireRecipient.v20240806.clientID)
    var client: User
    
    @Field(key: QuestionnaireRecipient.v20240806.status)
    var status: Status
    
    @Field(key: QuestionnaireRecipient.v20240806.sentAt)
    var sentAt: Date
    
    @OptionalField(key: QuestionnaireRecipient.v20240806.fields)
    var fields: [QRField]?
    
    @OptionalField(key: QuestionnaireRecipient.v20240806.viewedAt)
    var viewedAt: Date?
    
    @OptionalField(key: QuestionnaireRecipient.v20240806.submittedAt)
    var submittedAt: Date?
    
    @Timestamp(key: QuestionnaireRecipient.v20240806.createdAt, on: .create)
    var createdAt: Date?
    
    init() {}
    
    init(id: UUID? = nil,
         questionnaireID: Questionnaire.IDValue,
         clientID: User.IDValue,
         status: Status,
         sentAt: Date,
         fields: [QRField]? = nil,
         viewedAt: Date? = nil,
         submittedAt: Date? = nil
    ) {
        self.id = id
        self.$questionnaire.id = questionnaireID
        self.$client.id = clientID
        self.status = status
        self.sentAt = sentAt
        self.fields = fields
        self.viewedAt = viewedAt
        self.submittedAt = submittedAt
        self.createdAt = Date()
    }
}
