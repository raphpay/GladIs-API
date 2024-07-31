//
//  User.swift
//  
//
//  Created by Raphaël Payet on 07/02/2024.
//

import Fluent
import Vapor

final class User: Model, Content {
    static let schema: String = User.v20240207.schemaName
    
    @ID
    var id: UUID?
    
    @Field(key: User.v20240207.firstName)
    var firstName: String
    
    @Field(key: User.v20240207.lastName)
    var lastName: String
    
    @Field(key: User.v20240207.phoneNumber)
    var phoneNumber: String
    
    @Field(key: User.v20240207.email)
    var email: String
    
    @Field(key: User.v20240207.username)
    var username: String
    
    @Field(key: User.v20240207.password)
    var password: String
    
    @Field(key: User.v20240207.firstConnection)
    var firstConnection: Bool
    
    @OptionalField(key: User.v20240207.companyName)
    var companyName: String?
    
    @OptionalField(key: User.v20240207.products)
    var products: String?
    
    @OptionalField(key: User.v20240207.numberOfEmployees)
    var numberOfEmployees: Int?
    
    @OptionalField(key: User.v20240207.numberOfUsers)
    var numberOfUsers: Int?
    
    @OptionalField(key: User.v20240207.salesAmount)
    var salesAmount: Double?
    
    @OptionalField(key: User.v20240207.employeesIDs)
    var employeesIDs: [String]?
    
    @OptionalField(key: User.v20240207.managerID)
    var managerID: String?
    
    @OptionalField(key: User.v20240207.isBlocked)
    var isBlocked: Bool?

    @OptionalField(key: User.v20240207.modules)
    var modules: [Module]?

    @OptionalField(key: User.v20240207.isConnectionBlocked)
    var isConnectionBlocked: Bool?

    @OptionalField(key: User.v20240207.connectionFailedAttempts)
    var connectionFailedAttempts: Int?
    
    @Enum(key: "userType")
    var userType: UserType
    
    @Siblings(through: UserTabPivot.self,
              from: \.$user,
              to: \.$technicalDocumentationTab)
    var technicalDocumentationTabs: [TechnicalDocumentationTab]
    
    @Children(for: \.$user)
    var tokens: [Token]
    
    @Children(for: \.$user)
    var resetTokens: [PasswordResetToken]
    
    @Children(for: \.$sender)
    var sentMessages: [Message]
    
    @Children(for: \.$receiver)
    var receivedMessages: [Message]
    
    init() {}
    
    init(id: UUID? = nil,
         firstName: String, lastName: String, phoneNumber: String,
         username: String, password: String, email: String, firstConnection: Bool,
         userType: UserType,
         companyName: String? = nil, products: String? = nil,
         numberOfEmployees: Int? = nil, numberOfUsers: Int? = nil,
         salesAmount: Double? = nil, employeesIDs: [String]? = nil, managerID: String? = nil) {
        // Required
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.email = email
        self.username = username
        self.password = password
        self.firstConnection = firstConnection
        self.userType = userType
        // Optional
        self.companyName = companyName
        self.products = products
        self.numberOfEmployees = numberOfEmployees
        self.numberOfUsers = numberOfUsers
        self.salesAmount = salesAmount
        self.employeesIDs = employeesIDs
        self.managerID = managerID
    }
}
