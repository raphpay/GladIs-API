//
//  User+FieldKeys.swift
//
//
//  Created by Raphaël Payet on 31/07/2024.
//

import Fluent

extension User {
    enum v20240207 {
        static let schemaName = "users"
        static let id = FieldKey(stringLiteral: "id")
        static let firstName = FieldKey(stringLiteral: "firstName")
        static let lastName = FieldKey(stringLiteral: "lastName")
        static let phoneNumber = FieldKey(stringLiteral: "phoneNumber")
        static let companyName = FieldKey(stringLiteral: "companyName")
        static let email = FieldKey(stringLiteral: "email")
        static let firstConnection = FieldKey(stringLiteral: "firstConnection")
        static let products = FieldKey(stringLiteral: "products")
        static let modules = FieldKey(stringLiteral: "modules")
        static let technicalDocumentationTabs = FieldKey(stringLiteral: "technicalDocumentationTabs")
        static let numberOfEmployees = FieldKey(stringLiteral: "numberOfEmployees")
        static let numberOfUsers = FieldKey(stringLiteral: "numberOfUsers")
        static let salesAmount = FieldKey(stringLiteral: "salesAmount")
        static let employeesIDs = FieldKey(stringLiteral: "employeesIDs")
        static let managerID = FieldKey(stringLiteral: "managerID")
        static let isBlocked = FieldKey(stringLiteral: "isBlocked")
        static let isConnectionBlocked = FieldKey(stringLiteral: "isConnectionBlocked")
        static let connectionFailedAttempts = FieldKey(stringLiteral: "connectionFailedAttempts")
        
        
        static let username = FieldKey(stringLiteral: "username")
        static let password = FieldKey(stringLiteral: "password")
        
        static let userTypeEnum = FieldKey(stringLiteral: "userTypeEnum")
        static let userType = "userType"
        static let admin = "admin"
        static let client = "client"
        static let employee = "employee"
    }
    
    enum UserType: String, Codable {
        case employee, admin, client
    }
}
