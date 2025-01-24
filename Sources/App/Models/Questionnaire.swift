//
//  Questionnaire.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 22/01/2025.
//

import Vapor
import Fluent

final class Questionnaire: Model, Content {
    static let schema = Questionnaire.v20240806.schemaName

    @ID
    var id: UUID?

    @Field(key: Questionnaire.v20240806.title)
    var title: String
    
    @Field(key: Questionnaire.v20240806.fields)
    var fields: [QField]
    
    @Field(key: Questionnaire.v20240806.adminID)
    var adminID: User.IDValue
    
    @Timestamp(key: Questionnaire.v20240806.createdAt, on: .create)
    var createdAt: Date?
    
    @Field(key: Questionnaire.v20240806.sentAt)
    var sentAt: Date?
    
    @Field(key: Questionnaire.v20240806.sentCount)
    var sentCount: Int
    
    @Field(key: Questionnaire.v20240806.responseCount)
    var responseCount: Int
    
    @Children(for: \.$questionnaire)
    var questionnaireRecipients: [QuestionnaireRecipient]
    

    init() {}
    
    init(id: UUID? = nil,
         title: String,
         fields: [QField],
         adminID: User.IDValue,
         sentCount: Int = 0,
         responseCount: Int = 0,
         sentAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.fields = fields
        self.adminID = adminID
        self.sentCount = sentCount
        self.responseCount = responseCount
        self.createdAt = Date()
        self.sentAt = sentAt
    }
}
