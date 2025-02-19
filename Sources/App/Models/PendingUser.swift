//
//  PendingUser.swift
//
//
//  Created by Raphaël Payet on 12/02/2024.
//

import Vapor
import Fluent

final class PendingUser: Model, Content {
    static let schema = "pending_user_requests"

    @ID
    var id: UUID?
    
    @Field(key: PendingUser.v20240207.firstName)
    var firstName: String
    
    @Field(key: PendingUser.v20240207.lastName)
    var lastName: String
    
    @Field(key: PendingUser.v20240207.phoneNumber)
    var phoneNumber: String
    
    @Field(key: PendingUser.v20240207.companyName)
    var companyName: String
    
    @Field(key: PendingUser.v20240207.email)
    var email: String
    
    @Field(key: PendingUser.v20240207.products)
    var products: String?
    
    @OptionalField(key: PendingUser.v20240207.numberOfEmployees)
    var numberOfEmployees: Int?
    
    @OptionalField(key: PendingUser.v20240207.numberOfUsers)
    var numberOfUsers: Int?
    
    @OptionalField(key: PendingUser.v20240207.salesAmount)
    var salesAmount: Double?
    
    @OptionalField(key: PendingUser.v20240207.modules)
    var modules: [Module]?
    
    @Enum(key: PendingUser.v20240207.statusEnum)
    var status: PendingUser.StatusEnum
    
    @Children(for: \.$pendingUser)
    var potentialEmployees: [PotentialEmployee]

    init() { }

    init(id: UUID = UUID(), firstName: String, lastName: String,
         phoneNumber: String, companyName: String,
         email: String, products: String,
         numberOfEmployees: Int? = nil, numberOfUsers: Int? = nil,
        salesAmount: Double? = nil, status: PendingUser.StatusEnum = .pending) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.companyName = companyName
        self.email = email
        self.products = products
        self.numberOfEmployees = numberOfEmployees
        self.numberOfUsers = numberOfUsers
        self.salesAmount = salesAmount
        self.status = status
    }
}