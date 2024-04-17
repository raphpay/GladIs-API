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
    
    @Siblings(through: ModulePendingUserPivot.self,
              from: \.$pendingUser,
              to: \.$module)
    var modules: [Module]
    
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
    
    struct Input: Content {
        var id: UUID?
        let firstName: String
        let lastName: String
        let phoneNumber: String
        let companyName: String
        let email: String
        let products: String
        let numberOfEmployees: Int?
        let numberOfUsers: Int?
        let salesAmount: Double?
    }
    
    struct StatusInput: Content {
        let type: StatusEnum
    }
}

extension PendingUser {
    enum v20240207 {
        static let schemaName = "pending-users"
        static let id = FieldKey(stringLiteral: "id")
        static let firstName = FieldKey(stringLiteral: "firstName")
        static let lastName = FieldKey(stringLiteral: "lastName")
        static let phoneNumber = FieldKey(stringLiteral: "phoneNumber")
        static let companyName = FieldKey(stringLiteral: "companyName")
        static let email = FieldKey(stringLiteral: "email")
        static let products = FieldKey(stringLiteral: "products")
        static let modules = FieldKey(stringLiteral: "modules")
        static let numberOfEmployees = FieldKey(stringLiteral: "numberOfEmployees")
        static let numberOfUsers = FieldKey(stringLiteral: "numberOfUsers")
        static let salesAmount = FieldKey(stringLiteral: "salesAmount")
        
        static let statusEnum = FieldKey(stringLiteral: "statusEnum")
        static let status = "status"
        static let pending = "pending"
        static let inReview = "inReview"
        static let accepted = "accepted"
        static let rejected = "rejected"
    }
    
    enum StatusEnum: String, Codable {
        case pending, inReview, accepted, rejected
    }
    
    final class Status: Codable {
        var type: StatusEnum
    }
}
