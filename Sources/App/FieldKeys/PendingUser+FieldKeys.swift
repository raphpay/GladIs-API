//
//  PendingUser+FieldKeys.swift
//  GladIs-API
//
//  Created by Raphaël Payet on 19/02/2025.
//

import Fluent

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
